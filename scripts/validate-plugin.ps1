$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root '.codex-plugin\plugin.json'
$skillsRoot = Join-Path $root 'skills'
$requiredSkills = @(
  'ae-lfg',
  'ae-brainstorm',
  'ae-plan',
  'ae-work',
  'ae-review',
  'ae-refactor',
  'ae-task-loop',
  'ae-help',
  'ae-gate',
  'ae-recovery',
  'ae-review-contract',
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
)

$expectedSkillNames = @{
  'ae-lfg' = 'ae:lfg'
  'ae-brainstorm' = 'ae:brainstorm'
  'ae-plan' = 'ae:plan'
  'ae-work' = 'ae:work'
  'ae-review' = 'ae:review'
  'ae-refactor' = 'ae:refactor'
  'ae-task-loop' = 'ae:task-loop'
  'ae-help' = 'ae:help'
  'ae-gate' = 'ae:gate'
  'ae-recovery' = 'ae:recovery'
  'ae-review-contract' = 'ae:review-contract'
  'ae-swagger-parser' = 'ae:swagger-parser'
  'ae-prompt-optimize' = 'ae:prompt-optimize'
  'ae-document-review' = 'ae:document-review'
  'ae-save-rules' = 'ae:save-rules'
  'ae-handoff' = 'ae:handoff'
  'ae-frontend-design' = 'ae:frontend-design'
  'ae-test-browser' = 'ae:test-browser'
  'ae-sql' = 'ae:sql'
  'ae-figma-assets' = 'ae:figma-assets'
  'ae-update' = 'ae:update'
}

$triggerSamples = @{}
foreach ($skill in $requiredSkills) {
  $triggerSamples[$skill] = @("/$skill", $expectedSkillNames[$skill])
}

$routingCases = @(
  @{ Prompt = '/ae-help show available skills'; Skill = 'ae-help' },
  @{ Prompt = '/ae-plan build the next roadmap capability'; Skill = 'ae-plan' },
  @{ Prompt = '/ae-review review my changes'; Skill = 'ae-review' },
  @{ Prompt = '/ae-lfg build this feature end to end'; Skill = 'ae-lfg' },
  @{ Prompt = '/ae-task-loop fix type errors until green'; Skill = 'ae-task-loop' },
  @{ Prompt = '/ae-gate final proof'; Skill = 'ae-gate' },
  @{ Prompt = '/ae-recovery resume AE workflow'; Skill = 'ae-recovery' },
  @{ Prompt = '/ae-review-contract choose reviewers'; Skill = 'ae-review-contract' },
  @{ Prompt = '/ae-swagger-parser summarize OpenAPI'; Skill = 'ae-swagger-parser' },
  @{ Prompt = '/ae-prompt-optimize improve this prompt'; Skill = 'ae-prompt-optimize' },
  @{ Prompt = '/ae-document-review review this plan'; Skill = 'ae-document-review' },
  @{ Prompt = '/ae-save-rules remember this rule'; Skill = 'ae-save-rules' },
  @{ Prompt = '/ae-handoff create a continuation summary'; Skill = 'ae-handoff' },
  @{ Prompt = '/ae-frontend-design improve this UI'; Skill = 'ae-frontend-design' },
  @{ Prompt = '/ae-test-browser validate this page'; Skill = 'ae-test-browser' },
  @{ Prompt = '/ae-sql inspect this database'; Skill = 'ae-sql' },
  @{ Prompt = '/ae-figma-assets collect design files'; Skill = 'ae-figma-assets' },
  @{ Prompt = '/ae-update refresh plugin'; Skill = 'ae-update' }
)

$results = New-Object System.Collections.Generic.List[string]

function Fail($message) {
  Write-Error $message
  exit 1
}

function Pass($message) {
  $results.Add("PASS: $message") | Out-Null
}

function Get-FrontmatterField($text, $field) {
  $match = [regex]::Match($text, "(?m)^$field\s*:\s*(.+)$")
  if (-not $match.Success) {
    return $null
  }
  return $match.Groups[1].Value.Trim().Trim('"').Trim("'")
}

function Assert-File($path) {
  if (-not (Test-Path -LiteralPath $path)) {
    Fail "Missing expected file: $path"
  }
}

if (-not (Test-Path -LiteralPath $manifestPath)) {
  Fail "Missing manifest: $manifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
if ($manifest.name -ne 'ai-agent-engine-codex') {
  Fail "Unexpected plugin name: $($manifest.name)"
}
if ($manifest.skills -ne './skills/') {
  Fail "Manifest skills path must be ./skills/"
}
foreach ($forbiddenKey in @('commands', 'mcpServers', 'hooks')) {
  if ($manifest.PSObject.Properties.Name -contains $forbiddenKey) {
    Fail "Current plugin surface must not define $forbiddenKey in plugin manifest."
  }
}
if ($manifest.interface.displayName -ne 'AI Agent Engine for Codex') {
  Fail "Unexpected interface displayName: $($manifest.interface.displayName)"
}
foreach ($capability in @('Interactive', 'Read', 'Write')) {
  if (@($manifest.interface.capabilities) -notcontains $capability) {
    Fail "Missing interface capability: $capability"
  }
}
if ($manifest.version -ne '0.3.0') {
  Fail "Unexpected plugin version: $($manifest.version)"
}
if ($manifest.homepage -notlike '*github.com/1439437603/ai-agent-engine-codex*') {
  Fail 'Manifest homepage must point at this original project repository.'
}
Pass 'plugin manifest is parseable and declares the expected Codex 0.3 surface'

if (-not (Test-Path -LiteralPath $skillsRoot)) {
  Fail "Missing skills directory: $skillsRoot"
}

$actualSkillDirs = Get-ChildItem -Directory -LiteralPath $skillsRoot | ForEach-Object { $_.Name }
foreach ($skillDir in $actualSkillDirs) {
  if ($requiredSkills -notcontains $skillDir) {
    Fail "Unexpected skill directory in current pack: $skillDir"
  }
}

foreach ($skill in $requiredSkills) {
  $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
  Assert-File $skillPath

  $text = Get-Content -Raw -LiteralPath $skillPath
  if ($text -notmatch '(?s)^---\s.*?\bname:\s*.+?\bdescription:\s*.+?---') {
    Fail "Skill frontmatter must include name and description: $skillPath"
  }

  $name = Get-FrontmatterField $text 'name'
  $description = Get-FrontmatterField $text 'description'
  if ($name -ne $expectedSkillNames[$skill]) {
    Fail "Unexpected skill name in $skillPath. Expected '$($expectedSkillNames[$skill])', got '$name'."
  }
  if ([string]::IsNullOrWhiteSpace($description)) {
    Fail "Missing skill description in $skillPath"
  }
  foreach ($trigger in $triggerSamples[$skill]) {
    if ($description -notlike "*$trigger*") {
      Fail "Skill description for $name must include trigger '$trigger'."
    }
  }
}
Pass 'all required skills exist, have valid frontmatter, and include ae:* plus /ae-* triggers'

foreach ($case in $routingCases) {
  $skill = $case.Skill
  $prompt = $case.Prompt
  $alias = "/$skill"
  if (-not $prompt.Contains($alias)) {
    Fail "Routing case '$prompt' does not include expected alias '$alias'."
  }
  $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
  $text = Get-Content -Raw -LiteralPath $skillPath
  $description = Get-FrontmatterField $text 'description'
  if ($description -notlike "*$alias*") {
    Fail "Routing case '$prompt' cannot be satisfied because $skill description lacks '$alias'."
  }
}
Pass "representative routing eval set passed ($($routingCases.Count) cases)"

$blocked = @(
  'ae' + '-help tool',
  '.open' + 'code' + '/plugins',
  '.open' + 'code' + '\plugins',
  'open' + 'code',
  'migr' + 'ation',
  'migr' + 'ate',
  'migr' + 'ated',
  'V' + '1',
  'V' + '2',
  'V' + '3',
  (([string][char]0x8FC1) + ([string][char]0x79FB)),
  'disable' + '-model-invocation'
)

$scanFiles = Get-ChildItem -Recurse -File -LiteralPath $root |
  Where-Object {
    $_.FullName -notlike '*\scripts\validate-plugin.ps1' -and
    $_.FullName -notlike '*\.git\*'
  }

foreach ($file in $scanFiles) {
  $text = Get-Content -Raw -LiteralPath $file.FullName
  foreach ($pattern in $blocked) {
    if ($text -like "*$pattern*") {
      Fail "Found blocked old-positioning term in $($file.FullName)"
    }
  }
}
Pass 'positioning scan found no old-platform or conversion-story leftovers'

foreach ($script in @(
  'ae-gate.ps1',
  'ae-recovery.ps1',
  'ae-review-contract.ps1',
  'ae-swagger-parser.ps1',
  'ae-prompt-optimize.ps1',
  'ae-help-catalog.ps1',
  'ae-save-rules.ps1',
  'ae-handoff.ps1',
  'ae-reviewer-catalog.ps1',
  'ae-sql.ps1',
  'ae-figma-assets.ps1',
  'ae-update.ps1',
  'register-local-marketplace.ps1',
  'unregister-local-marketplace.ps1',
  'test-core-tools.ps1',
  'test-roadmap-surface.ps1'
)) {
  Assert-File (Join-Path $root "scripts\$script")
}
Pass 'current scripts and test suites are present'

foreach ($asset in @(
  'tests\fixtures\swagger\openapi-3-basic.json',
  'tests\fixtures\swagger\swagger-2-basic.json',
  'tests\fixtures\swagger\golden\openapi-3-overview.md',
  'tests\fixtures\swagger\golden\swagger-2-detail.md',
  '.github\workflows\validate.yml'
)) {
  Assert-File (Join-Path $root $asset)
}
$reviewerCount = @(Get-ChildItem -File -LiteralPath (Join-Path $root 'references\reviewers') -Filter '*.md').Count
if ($reviewerCount -ne 26) {
  Fail "Expected 26 reviewer references, got $reviewerCount"
}
Assert-File (Join-Path $root 'references\reviewers\data-evolution-reviewer.md')
Pass 'fixtures, workflow, and reviewer references are present'

$readmePath = Join-Path $root 'README.md'
Assert-File $readmePath
$readme = Get-Content -Raw -LiteralPath $readmePath
foreach ($needle in @(
  'original Codex-native engineering operating system',
  'Current Innovation Surface',
  'Planned Optimization',
  'Planned Development',
  'test-roadmap-surface.ps1',
  'Figma export',
  'SQL execution',
  'Browser acceptance automation'
)) {
  if ($readme -notlike "*$needle*") {
    Fail "README must document '$needle'."
  }
}
Pass 'README documents current innovation surface and planned capabilities'

Write-Output 'AI Agent Engine Codex plugin validation'
Write-Output "Root: $root"
foreach ($result in $results) {
  Write-Output $result
}
Write-Output "PASS: automated validation completed with $($results.Count) check groups."
