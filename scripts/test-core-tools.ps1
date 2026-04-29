$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$scriptsRoot = Join-Path $root 'scripts'
$skillsRoot = Join-Path $root 'skills'
$results = New-Object System.Collections.Generic.List[string]

function Fail($message) {
  Write-Error $message
  exit 1
}

function Pass($message) {
  $results.Add("PASS: $message") | Out-Null
}

function Run-JsonScript($scriptName, $arguments) {
  $scriptPath = Join-Path $scriptsRoot $scriptName
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    Fail "Missing script: $scriptPath"
  }

  $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @arguments
  if ($LASTEXITCODE -ne 0) {
    Fail "$scriptName exited with code $LASTEXITCODE"
  }

  try {
    return ($output -join "`n") | ConvertFrom-Json
  } catch {
    Fail "$scriptName did not return JSON. Output: $($output -join "`n")"
  }
}

function New-FixtureWorkspace {
  $workspace = Join-Path ([System.IO.Path]::GetTempPath()) ("ae-codex-core-tools-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path (Join-Path $workspace 'docs\ae\brainstorms') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $workspace 'docs\ae\plans') | Out-Null
  Set-Content -Encoding UTF8 -LiteralPath (Join-Path $workspace 'docs\ae\brainstorms\2026-04-29-demo-requirements.md') -Value '# Demo requirements'
  Set-Content -Encoding UTF8 -LiteralPath (Join-Path $workspace 'docs\ae\plans\2026-04-29-demo-plan.md') -Value '# Demo plan'
  return $workspace
}

$workspace = New-FixtureWorkspace

$gate = Run-JsonScript 'ae-gate.ps1' @(
  '-Workflow', 'lfg',
  '-Checkpoint', 'before_work',
  '-Root', $workspace,
  '-RequirementsPath', 'docs/ae/brainstorms/2026-04-29-demo-requirements.md',
  '-PlanPath', 'docs/ae/plans/2026-04-29-demo-plan.md',
  '-ValidationCommand', 'scripts/validate-plugin.ps1'
)
if ($gate.status -ne 'pass') {
  Fail "Expected gate pass, got $($gate.status): $($gate.blockers -join '; ')"
}
Pass 'ae-gate passes when required evidence exists'

$missingGate = Run-JsonScript 'ae-gate.ps1' @(
  '-Workflow', 'lfg',
  '-Checkpoint', 'before_work',
  '-Root', $workspace,
  '-PlanPath', 'docs/ae/plans/missing-plan.md'
)
if ($missingGate.status -ne 'block') {
  Fail "Expected gate block for missing plan, got $($missingGate.status)"
}
Pass 'ae-gate blocks when required plan evidence is missing'

$recovery = Run-JsonScript 'ae-recovery.ps1' @(
  '-Phase', 'lfg',
  '-Root', $workspace
)
if ($recovery.recommendedNextSkill -ne 'ae:work') {
  Fail "Expected ae:work recovery recommendation, got $($recovery.recommendedNextSkill)"
}
if (-not $recovery.candidates.planPath) {
  Fail 'Expected recovery to find a plan path.'
}
Pass 'ae-recovery recommends the next skill from existing artifacts'

$contract = Run-JsonScript 'ae-review-contract.ps1' @(
  '-Kind', 'code',
  '-Mode', 'autofix',
  '-HasSecurity',
  '-HasApi',
  '-ChangedLines', '250'
)
if ($contract.kind -ne 'code' -or $contract.mode -ne 'autofix') {
  Fail 'Review contract did not preserve kind/mode.'
}
foreach ($reviewer in @('correctness-reviewer', 'testing-reviewer', 'security-reviewer', 'api-contract-reviewer')) {
  if (@($contract.reviewers) -notcontains $reviewer) {
    Fail "Expected reviewer missing from contract: $reviewer"
  }
}
Pass 'ae-review-contract selects baseline and risk-specific reviewers'

foreach ($skill in @('ae-gate', 'ae-recovery', 'ae-review-contract')) {
  $skillPath = Join-Path $skillsRoot "$skill\SKILL.md"
  if (-not (Test-Path -LiteralPath $skillPath)) {
    Fail "Missing skill wrapper: $skillPath"
  }
}
Pass 'core tool replacement skills exist'

Write-Output 'AI Agent Engine Codex core tool tests'
Write-Output "Fixture: $workspace"
foreach ($result in $results) {
  Write-Output $result
}
Write-Output "PASS: core tool tests completed with $($results.Count) check groups."
