param(
  [ValidateSet('lfg', 'work')]
  [string]$Workflow = 'work',

  [ValidateSet('start', 'before_plan', 'before_work', 'before_review', 'final')]
  [string]$Checkpoint = 'final',

  [string]$Root = (Get-Location).Path,
  [string]$RequirementsPath,
  [string]$PlanPath,
  [string[]]$ValidationCommand = @(),

  [ValidateSet('passed', 'failed', 'not_run', 'not_applicable')]
  [string]$ReviewStatus = 'not_run',

  [ValidateSet('passed', 'failed', 'not_run', 'not_applicable')]
  [string]$BrowserTestStatus = 'not_applicable',

  [string[]]$GitOperation = @(),
  [switch]$UserAuthorizedGitWrite,
  [string]$NoCodeChangeReason,
  [string]$Notes,
  [switch]$WriteProof
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoPath($root, $path) {
  if ([string]::IsNullOrWhiteSpace($path)) {
    return $null
  }
  if ([System.IO.Path]::IsPathRooted($path)) {
    return $path
  }
  return Join-Path $root $path
}

function Add-Blocker([System.Collections.Generic.List[string]]$blockers, [string]$message) {
  $blockers.Add($message) | Out-Null
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$blockers = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$evidence = [ordered]@{}

$requirementsFullPath = Resolve-RepoPath $rootPath $RequirementsPath
$planFullPath = Resolve-RepoPath $rootPath $PlanPath

if ($requirementsFullPath) {
  $exists = Test-Path -LiteralPath $requirementsFullPath
  $evidence.requirementsPath = $RequirementsPath
  $evidence.requirementsExists = $exists
  if (-not $exists) {
    Add-Blocker $blockers "requirements_path does not exist: $RequirementsPath"
  }
}

if ($planFullPath) {
  $exists = Test-Path -LiteralPath $planFullPath
  $evidence.planPath = $PlanPath
  $evidence.planExists = $exists
  if (-not $exists) {
    Add-Blocker $blockers "plan_path does not exist: $PlanPath"
  }
}

if ($Checkpoint -in @('before_work', 'before_review', 'final') -and [string]::IsNullOrWhiteSpace($PlanPath)) {
  Add-Blocker $blockers "$Checkpoint requires plan_path"
}

if ($Checkpoint -in @('before_review', 'final') -and @($ValidationCommand).Count -eq 0) {
  Add-Blocker $blockers "$Checkpoint requires at least one validation command that was actually run"
}

if ($Checkpoint -eq 'final') {
  if ($ReviewStatus -notin @('passed', 'not_applicable')) {
    Add-Blocker $blockers "final requires review_status passed or not_applicable"
  }
  if ($BrowserTestStatus -eq 'failed') {
    $warnings.Add('browser_test_status is failed; delivery may be risky even if not blocking') | Out-Null
  }
}

if (@($GitOperation).Count -gt 0 -and -not $UserAuthorizedGitWrite.IsPresent) {
  Add-Blocker $blockers 'git operations were reported without user_authorized_git_write'
}

if ([string]::IsNullOrWhiteSpace($NoCodeChangeReason) -and $Workflow -eq 'work' -and $Checkpoint -eq 'final') {
  $warnings.Add('no_code_change_reason was not provided; make sure there were actual scoped changes or explain why none were needed') | Out-Null
}

$evidence.validationCommands = @($ValidationCommand)
$evidence.reviewStatus = $ReviewStatus
$evidence.browserTestStatus = $BrowserTestStatus
$evidence.gitOperations = @($GitOperation)
$evidence.userAuthorizedGitWrite = $UserAuthorizedGitWrite.IsPresent

$status = if ($blockers.Count -eq 0) { 'pass' } else { 'block' }
$proofPath = $null
$shouldWriteProof = $WriteProof.IsPresent -or $Checkpoint -eq 'final'

if ($shouldWriteProof) {
  $gateDir = Join-Path $rootPath 'docs\ae\gates'
  New-Item -ItemType Directory -Force -Path $gateDir | Out-Null
  $timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH-mm-ss-fffZ')
  $proofPath = Join-Path $gateDir "$timestamp-$Workflow-$Checkpoint.json"
}

$result = [ordered]@{
  workflow = $Workflow
  checkpoint = $Checkpoint
  status = $status
  blockers = @($blockers)
  warnings = @($warnings)
  evidence = $evidence
  notes = $Notes
  proofPath = $proofPath
}

if ($proofPath) {
  $result | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 -LiteralPath $proofPath
}

$result | ConvertTo-Json -Depth 8
