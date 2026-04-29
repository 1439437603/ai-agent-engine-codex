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

$triggerSamples = @{
  'ae-lfg' = @('/ae-lfg', 'ae:lfg')
  'ae-brainstorm' = @('/ae-brainstorm', 'ae:brainstorm')
  'ae-plan' = @('/ae-plan', 'ae:plan')
  'ae-work' = @('/ae-work', 'ae:work')
  'ae-review' = @('/ae-review', 'ae:review')
  'ae-refactor' = @('/ae-refactor', 'ae:refactor')
  'ae-task-loop' = @('/ae-task-loop', 'ae:task-loop')
  'ae-help' = @('/ae-help', 'ae:help')
  'ae-gate' = @('/ae-gate', 'ae:gate')
  'ae-recovery' = @('/ae-recovery', 'ae:recovery')
  'ae-review-contract' = @('/ae-review-contract', 'ae:review-contract')
  'ae-swagger-parser' = @('/ae-swagger-parser', 'ae:swagger-parser')
  'ae-prompt-optimize' = @('/ae-prompt-optimize', 'ae:prompt-optimize')
  'ae-document-review' = @('/ae-document-review', 'ae:document-review')
  'ae-save-rules' = @('/ae-save-rules', 'ae:save-rules')
  'ae-handoff' = @('/ae-handoff', 'ae:handoff')
  'ae-frontend-design' = @('/ae-frontend-design', 'ae:frontend-design')
  'ae-test-browser' = @('/ae-test-browser', 'ae:test-browser')
  'ae-sql' = @('/ae-sql', 'ae:sql')
  'ae-figma-assets' = @('/ae-figma-assets', 'ae:figma-assets')
  'ae-update' = @('/ae-update', 'ae:update')
}

$routingCases = @(
  @{ Prompt = '/ae-help show available skills'; Skill = 'ae-help' },
  @{ Prompt = '/ae-plan migrate this plugin'; Skill = 'ae-plan' },
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
if ($manifest.PSObject.Properties.Name -contains 'commands') {
  Fail 'V1 must not define native command registry in plugin manifest.'
}
if ($manifest.PSObject.Properties.Name -contains 'mcpServers') {
  Fail 'V1 must not define MCP servers in plugin manifest.'
}
if ($manifest.PSObject.Properties.Name -contains 'hooks') {
  Fail 'V1 must not define hooks in plugin manifest.'
}
if ($manifest.interface.displayName -ne 'AI Agent Engine for Codex') {
  Fail "Unexpected interface displayName: $($manifest.interface.displayName)"
}
$capabilities = @($manifest.interface.capabilities)
foreach ($capability in @('Interactive', 'Read', 'Write')) {
  if ($capabilities -notcontains $capability) {
    Fail "Missing interface capability: $capability"
  }
}
if ($manifest.version -ne '0.3.0') {
  Fail "Unexpected plugin version: $($manifest.version)"
}
Pass 'plugin manifest is parseable and declares the expected Codex 0.3 surface'

if (-not (Test-Path -LiteralPath $skillsRoot)) {
  Fail "Missing skills directory: $skillsRoot"
}

$actualSkillDirs = Get-ChildItem -Directory -LiteralPath $skillsRoot | ForEach-Object { $_.Name }
foreach ($skillDir in $actualSkillDirs) {
  if ($requiredSkills -notcontains $skillDir) {
    Fail "Unexpected skill directory in V1 pack: $skillDir"
  }
}

foreach ($skill in $requiredSkills) {
  $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
  if (-not (Test-Path -LiteralPath $skillPath)) {
    Fail "Missing required skill file: $skillPath"
  }

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
  if ($text -match '\]\((references/[^)]+)\)') {
    foreach ($match in [regex]::Matches($text, '\]\((references/[^)]+)\)')) {
      $refPath = Join-Path (Split-Path -Parent $skillPath) $match.Groups[1].Value
      if (-not (Test-Path -LiteralPath $refPath)) {
        Fail "Missing skill reference '$($match.Groups[1].Value)' from $skillPath"
      }
    }
  }
}
Pass 'all required skills exist, have valid frontmatter, and include ae:* plus /ae-* triggers'

foreach ($case in $routingCases) {
  $skill = $case.Skill
  $prompt = $case.Prompt
  $alias = ($triggerSamples[$skill] | Where-Object { $_ -like '/ae-*' } | Select-Object -First 1)
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
  '.opencode' + '/plugins',
  '.opencode' + '\plugins',
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
    if ($text.Contains($pattern)) {
      Fail "Found incompatible leftover '$pattern' in $($file.FullName)"
    }
  }
}
Pass 'compatibility scan found no blocked opencode-only tool or plugin leftovers'

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
  'test-migration-surface.ps1'
)) {
  $scriptPath = Join-Path $root "scripts\$script"
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    Fail "Missing core script: $scriptPath"
  }
}
Pass 'migrated scripts and test suites are present'

foreach ($fixture in @(
  'tests\fixtures\swagger\openapi-3-basic.json',
  'tests\fixtures\swagger\swagger-2-basic.json',
  'tests\fixtures\swagger\golden\openapi-3-overview.md',
  'tests\fixtures\swagger\golden\swagger-2-detail.md',
  '.github\workflows\validate.yml'
)) {
  $fixturePath = Join-Path $root $fixture
  if (-not (Test-Path -LiteralPath $fixturePath)) {
    Fail "Missing expected migration asset: $fixturePath"
  }
}
$reviewerCount = @(Get-ChildItem -File -LiteralPath (Join-Path $root 'references\reviewers') -Filter '*.md').Count
if ($reviewerCount -ne 26) {
  Fail "Expected 26 reviewer references, got $reviewerCount"
}
Pass 'fixtures, workflow, and reviewer references are present'

$readmePath = Join-Path $root 'README.md'
if (-not (Test-Path -LiteralPath $readmePath)) {
  Fail "Missing README: $readmePath"
}
$readme = Get-Content -Raw -LiteralPath $readmePath
foreach ($needle in @(
  'skill-first plugin',
  '0.3 Migration Surface',
  'V3 Boundaries',
  'does not update global Codex marketplace configuration automatically',
  'Swagger parsing',
  'Figma export',
  'SQL execution',
  'browser automation'
)) {
  if ($readme -notlike "*$needle*") {
    Fail "README must document '$needle'."
  }
}
Pass 'README documents activation boundary and deferred V2 capabilities'

Write-Output 'AI Agent Engine Codex plugin validation'
Write-Output "Root: $root"
foreach ($result in $results) {
  Write-Output $result
}
Write-Output "PASS: automated validation completed with $($results.Count) check groups."
