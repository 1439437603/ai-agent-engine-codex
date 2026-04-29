param(
  [Parameter(Mandatory = $true)]
  [string]$ConnectionString,
  [Parameter(Mandatory = $true)]
  [string]$Query,
  [switch]$AllowWrite
)

$ErrorActionPreference = 'Stop'

$trimmed = $Query.Trim()
$isReadOnly = $trimmed -match '^(?i)\s*(select|with|show|describe|explain)\b'
if (-not $isReadOnly -and -not $AllowWrite.IsPresent) {
  [ordered]@{
    status = 'blocked'
    reason = 'Write-like SQL is blocked by default. Re-run with explicit review and AllowWrite only in a controlled environment.'
    redactedConnection = '<redacted>'
  } | ConvertTo-Json -Depth 5
  exit 0
}

[ordered]@{
  status = 'planned'
  mode = if ($isReadOnly) { 'read-only' } else { 'write-authorized' }
  redactedConnection = '<redacted>'
  queryPreview = $trimmed.Substring(0, [Math]::Min(120, $trimmed.Length))
  note = 'This Codex wrapper does not execute database queries yet; it classifies intent and enforces safe defaults.'
} | ConvertTo-Json -Depth 5
