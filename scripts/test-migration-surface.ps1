$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$scriptsRoot = Join-Path $root 'scripts'
$skillsRoot = Join-Path $root 'skills'
$fixturesRoot = Join-Path $root 'tests\fixtures'
$results = New-Object System.Collections.Generic.List[string]

function Fail($message) {
  Write-Error $message
  exit 1
}

function Pass($message) {
  $results.Add("PASS: $message") | Out-Null
}

function Run-TextScript($scriptName, $arguments) {
  $scriptPath = Join-Path $scriptsRoot $scriptName
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    Fail "Missing script: $scriptPath"
  }
  $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @arguments
  if ($LASTEXITCODE -ne 0) {
    Fail "$scriptName exited with code $LASTEXITCODE"
  }
  return ($output -join "`n").Trim()
}

function Run-JsonScript($scriptName, $arguments) {
  $text = Run-TextScript $scriptName $arguments
  try {
    return $text | ConvertFrom-Json
  } catch {
    Fail "$scriptName did not return JSON. Output: $text"
  }
}

function Assert-File($path) {
  if (-not (Test-Path -LiteralPath $path)) {
    Fail "Missing expected file: $path"
  }
}

function Normalize-Text($text) {
  return ($text -replace "`r`n", "`n").Trim()
}

$workspace = Join-Path ([System.IO.Path]::GetTempPath()) ("ae-codex-migration-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $workspace | Out-Null

$marketplaceRoot = Join-Path $workspace 'marketplace-root'
$cacheRoot = Join-Path $workspace 'cache'
$marketplace = Join-Path $marketplaceRoot '.agents\plugins\marketplace.json'
$register = Run-JsonScript 'register-local-marketplace.ps1' @('-PluginRoot', $root, '-MarketplaceRoot', $marketplaceRoot, '-CacheRoot', $cacheRoot)
if ($register.status -ne 'registered') { Fail "Marketplace register failed: $($register.status)" }
$marketplaceJson = Get-Content -Raw -LiteralPath $marketplace | ConvertFrom-Json
if (@($marketplaceJson.plugins).Count -ne 1 -or $marketplaceJson.plugins[0].name -ne 'ai-agent-engine-codex') {
  Fail 'Marketplace entry was not created correctly.'
}
if ($marketplaceJson.plugins[0].source.path -ne './plugins/ai-agent-engine-codex') {
  Fail "Marketplace entry points at unexpected plugin path: $($marketplaceJson.plugins[0].source.path)"
}
Assert-File (Join-Path $marketplaceRoot 'plugins\ai-agent-engine-codex\.codex-plugin\plugin.json')
Assert-File (Join-Path $cacheRoot 'ae-local\ai-agent-engine-codex\0.3.0\.codex-plugin\plugin.json')
$unregister = Run-JsonScript 'unregister-local-marketplace.ps1' @('-PluginName', 'ai-agent-engine-codex', '-MarketplaceRoot', $marketplaceRoot, '-CacheRoot', $cacheRoot)
if ($unregister.status -ne 'unregistered') { Fail "Marketplace unregister failed: $($unregister.status)" }
if (Test-Path -LiteralPath (Join-Path $marketplaceRoot 'plugins\ai-agent-engine-codex')) {
  Fail 'Marketplace unregister did not remove marketplace plugin copy.'
}
if (Test-Path -LiteralPath (Join-Path $cacheRoot 'ae-local\ai-agent-engine-codex')) {
  Fail 'Marketplace unregister did not remove cache plugin path.'
}

$pathOnlyRoot = Join-Path $workspace 'path-only-root'
$pathOnlyMarketplace = Join-Path $pathOnlyRoot 'marketplace.json'
$pathOnlyRegister = Run-JsonScript 'register-local-marketplace.ps1' @('-PluginRoot', $root, '-MarketplacePath', $pathOnlyMarketplace, '-CacheRoot', $cacheRoot)
if ($pathOnlyRegister.marketplaceRoot -ne $pathOnlyRoot) {
  Fail "MarketplacePath-only registration inferred unexpected root: $($pathOnlyRegister.marketplaceRoot)"
}
Assert-File (Join-Path $pathOnlyRoot 'plugins\ai-agent-engine-codex\.codex-plugin\plugin.json')
$pathOnlyUnregister = Run-JsonScript 'unregister-local-marketplace.ps1' @('-PluginName', 'ai-agent-engine-codex', '-MarketplacePath', $pathOnlyMarketplace, '-CacheRoot', $cacheRoot)
if ($pathOnlyUnregister.status -ne 'unregistered') { Fail "MarketplacePath-only unregister failed: $($pathOnlyUnregister.status)" }
if (Test-Path -LiteralPath (Join-Path $pathOnlyRoot 'plugins\ai-agent-engine-codex')) {
  Fail 'MarketplacePath-only unregister did not remove inferred-root plugin copy.'
}
Pass 'marketplace register/unregister creates supported root, path-only root, and cache entries'

$overview = Run-TextScript 'ae-swagger-parser.ps1' @(
  '-Source', (Join-Path $fixturesRoot 'swagger\openapi-3-basic.json'),
  '-Mode', 'overview'
)
$overviewGolden = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $fixturesRoot 'swagger\golden\openapi-3-overview.md')
if ((Normalize-Text $overview) -ne (Normalize-Text $overviewGolden)) { Fail 'OpenAPI overview output does not match golden fixture.' }
$detail = Run-TextScript 'ae-swagger-parser.ps1' @(
  '-Source', (Join-Path $fixturesRoot 'swagger\swagger-2-basic.json'),
  '-Mode', 'detail',
  '-Method', 'GET',
  '-Path', '/orders/{id}'
)
$detailGolden = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $fixturesRoot 'swagger\golden\swagger-2-detail.md')
if ((Normalize-Text $detail) -ne (Normalize-Text $detailGolden)) { Fail 'Swagger 2 detail output does not match golden fixture.' }
Pass 'swagger parser matches overview and detail golden fixtures'

$help = Run-TextScript 'ae-help-catalog.ps1' @('-Root', $root)
foreach ($needle in @('ae:swagger-parser', 'ae:prompt-optimize', 'ae:document-review', 'ae:update', 'ae:figma-assets')) {
  if ($help -notlike "*$needle*") { Fail "Dynamic help missing $needle" }
}
Pass 'dynamic help catalog includes migrated skills'

$prompt = Run-JsonScript 'ae-prompt-optimize.ps1' @('-Prompt', '帮我做一个登录页', '-Auto')
if (-not $prompt.optimizedPrompt -or $prompt.mode -ne 'auto') { Fail 'Prompt optimizer did not return optimized auto prompt.' }
Pass 'prompt optimizer returns structured optimized prompt'

$handoff = Run-JsonScript 'ae-handoff.ps1' @(
  '-Root', $workspace,
  '-Title', 'demo handoff',
  '-Goal', 'continue migration',
  '-Status', 'running',
  '-Evidence', 'tests pass',
  '-NextStep', 'continue'
)
Assert-File (Join-Path $workspace $handoff.path)
$rules = Run-JsonScript 'ae-save-rules.ps1' @(
  '-Root', $workspace,
  '-Category', 'runtime',
  '-Content', 'Always verify before completion.'
)
Assert-File (Join-Path $workspace $rules.path)
Pass 'handoff and save-rules write durable docs/ae artifacts'

$reviewers = Run-JsonScript 'ae-reviewer-catalog.ps1' @('-Root', $root)
if (@($reviewers.reviewers).Count -ne 26) { Fail "Expected 26 reviewers, got $(@($reviewers.reviewers).Count)" }
$contract = Run-JsonScript 'ae-review-contract.ps1' @('-Kind', 'code', '-Mode', 'autofix', '-HasSecurity')
if (@($contract.reviewers) -notcontains 'security-reviewer') { Fail 'Review contract did not select security-reviewer.' }
Pass 'reviewer catalog exposes 26 reviewers and contract can select them'

$sql = Run-JsonScript 'ae-sql.ps1' @('-ConnectionString', 'Server=demo;Database=app;', '-Query', 'DELETE FROM users')
if ($sql.status -ne 'blocked') { Fail 'SQL wrapper must block write statements by default.' }
$figma = Run-JsonScript 'ae-figma-assets.ps1' @('-SourcePath', $workspace, '-OutputPath', (Join-Path $workspace 'figma-assets'))
if ($figma.status -ne 'collected') { Fail 'Figma assets placeholder should collect authorized local paths.' }
Pass 'SQL and Figma wrappers enforce safe default boundaries'

foreach ($skill in @(
  'ae-swagger-parser',
  'ae-prompt-optimize',
  'ae-document-review',
  'ae-save-rules',
  'ae-handoff',
  'ae-frontend-design',
  'ae-test-browser',
  'ae-sql',
  'ae-figma-assets',
  'ae-update'
)) {
  Assert-File (Join-Path $skillsRoot "$skill\SKILL.md")
}
Pass 'remaining migrated skill surfaces exist'

Assert-File (Join-Path $root '.github\workflows\validate.yml')
Pass 'GitHub Actions validation workflow exists'

Write-Output 'AI Agent Engine Codex migration surface tests'
Write-Output "Fixture workspace: $workspace"
foreach ($result in $results) {
  Write-Output $result
}
Write-Output "PASS: migration surface tests completed with $($results.Count) check groups."
