param(
  [Parameter(Mandatory = $true)]
  [string]$Prompt,
  [switch]$Auto
)

$ErrorActionPreference = 'Stop'

$clean = ($Prompt -replace '^[/@]\S+\s*', '').Trim()
$mode = if ($Auto.IsPresent) { 'auto' } else { 'confirm' }
$optimized = @(
  'Please execute the task using this structure:',
  '',
  'Goal:',
  $clean,
  '',
  'Execution requirements:',
  '1. Read relevant repository context and constraints first.',
  '2. Define completion criteria and minimum useful verification.',
  '3. Make the smallest viable change and avoid unrelated scope expansion.',
  '4. Run verification and read real output.',
  '5. Report goal, result, evidence, risks, and next step.'
) -join "`n"

[ordered]@{
  status = 'optimized'
  mode = $mode
  optimizedPrompt = $optimized
  nextStep = if ($Auto.IsPresent) { 'Use the optimized prompt directly in the current Codex session.' } else { 'Review the optimized prompt before execution.' }
} | ConvertTo-Json -Depth 5
