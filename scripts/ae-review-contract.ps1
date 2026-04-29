param(
  [ValidateSet('document', 'plan', 'test', 'general', 'code')]
  [string]$Kind = 'code',

  [ValidateSet('interactive', 'headless', 'report-only', 'autofix')]
  [string]$Mode = 'interactive',

  [switch]$HasUi,
  [switch]$HasSecurity,
  [switch]$HasCli,
  [switch]$HasTooling,
  [switch]$HasAgentConfig,
  [switch]$HasPerformance,
  [switch]$HasApi,
  [switch]$HasReliability,
  [switch]$HasDataEvolution,
  [switch]$HasConfig,
  [switch]$HasInfra,
  [switch]$HasDatabase,
  [switch]$HasScript,
  [int]$ChangedLines = 0,
  [int]$RequirementCount = 0,
  [switch]$HasArchitectureDecision,
  [switch]$HasProductClaim,
  [switch]$IsHighRiskDomain,
  [switch]$HasNewAbstraction
)

$ErrorActionPreference = 'Stop'

function Add-Unique([System.Collections.Generic.List[string]]$items, [string]$item) {
  if (-not $items.Contains($item)) {
    $items.Add($item) | Out-Null
  }
}

$reviewers = New-Object System.Collections.Generic.List[string]

if ($Kind -eq 'code') {
  foreach ($reviewer in @('correctness-reviewer', 'testing-reviewer', 'maintainability-reviewer', 'standards-reviewer')) {
    Add-Unique $reviewers $reviewer
  }
} else {
  foreach ($reviewer in @('coherence-reviewer', 'feasibility-reviewer', 'product-lens-reviewer', 'adversarial-reviewer')) {
    Add-Unique $reviewers $reviewer
  }
}

if ($HasSecurity -or $IsHighRiskDomain) { Add-Unique $reviewers 'security-reviewer' }
if ($HasApi) { Add-Unique $reviewers 'api-contract-reviewer' }
if ($HasPerformance) { Add-Unique $reviewers 'performance-reviewer' }
if ($HasReliability -or $HasInfra) { Add-Unique $reviewers 'reliability-reviewer' }
if ($HasDataEvolution -or $HasDatabase) { Add-Unique $reviewers 'data-evolution-reviewer' }
if ($HasTooling -or $HasAgentConfig -or $HasCli) { Add-Unique $reviewers 'agent-native-reviewer' }
if ($HasUi) { Add-Unique $reviewers 'design-lens-reviewer' }
if ($HasArchitectureDecision -or $HasNewAbstraction -or $ChangedLines -ge 200) { Add-Unique $reviewers 'architecture-strategist' }
if ($HasProductClaim -or $RequirementCount -ge 5) { Add-Unique $reviewers 'product-lens-reviewer' }
if ($HasScript -or $HasConfig) { Add-Unique $reviewers 'standards-reviewer' }

$documentType = if ($Kind -in @('plan', 'test', 'general')) { $Kind } elseif ($Kind -eq 'document') { 'requirements' } else { $null }
$gate = if ($Kind -eq 'code') {
  'P0/P1 findings block delivery unless mode is report-only.'
} else {
  'Document review is a quality gate for requirements, plans, and test specs.'
}

[ordered]@{
  kind = $Kind
  documentType = $documentType
  mode = $Mode
  reviewers = @($reviewers)
  gate = $gate
  rules = @(
    'Findings first, ordered by severity.',
    'P0/P1 issues require a fix or explicit risk acceptance.',
    'Report residual risk and unverified areas.'
  )
} | ConvertTo-Json -Depth 6
