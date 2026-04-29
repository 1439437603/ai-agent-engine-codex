param(
  [ValidateSet('brainstorm', 'plan', 'work', 'review', 'lfg')]
  [string]$Phase = 'lfg',
  [string]$Root = (Get-Location).Path,
  [string]$ExpectedOriginFingerprint
)

$ErrorActionPreference = 'Stop'

function Get-LatestFile($root, $relativePath, $pattern) {
  $dir = Join-Path $root $relativePath
  if (-not (Test-Path -LiteralPath $dir)) {
    return $null
  }
  $file = Get-ChildItem -File -LiteralPath $dir -Filter $pattern |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1
  if (-not $file) {
    return $null
  }
  return ($file.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/')
}

function Resolve-NextSkill($phase, $requirementsPath, $planPath) {
  switch ($phase) {
    'brainstorm' {
      if ($requirementsPath) { return 'ae:plan' }
      return 'ae:brainstorm'
    }
    'plan' {
      if ($planPath) { return 'ae:work' }
      return 'ae:plan'
    }
    'work' {
      if ($planPath) { return 'ae:work' }
      if ($requirementsPath) { return 'ae:plan' }
      return 'ae:brainstorm'
    }
    'review' {
      if ($planPath) { return 'ae:review' }
      return 'ae:plan'
    }
    default {
      if ($planPath) { return 'ae:work' }
      if ($requirementsPath) { return 'ae:plan' }
      return 'ae:brainstorm'
    }
  }
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$requirementsPath = Get-LatestFile $rootPath 'docs\ae\brainstorms' '*requirements*.md'
$planPath = Get-LatestFile $rootPath 'docs\ae\plans' '*plan*.md'
$gateProofPath = Get-LatestFile $rootPath 'docs\ae\gates' '*.json'
$recommendedNextSkill = Resolve-NextSkill $Phase $requirementsPath $planPath

$confidence = if ($planPath) {
  'high'
} elseif ($requirementsPath) {
  'medium'
} else {
  'low'
}

[ordered]@{
  phase = $Phase
  status = if ($requirementsPath -or $planPath -or $gateProofPath) { 'recoverable' } else { 'empty' }
  recommendedNextSkill = $recommendedNextSkill
  fallbackSkill = 'ae:brainstorm'
  confidence = $confidence
  expectedOriginFingerprint = $ExpectedOriginFingerprint
  candidates = [ordered]@{
    requirementsPath = $requirementsPath
    planPath = $planPath
    gateProofPath = $gateProofPath
  }
} | ConvertTo-Json -Depth 6
