param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [switch]$SkipPull
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$branch = (& git -C $rootPath branch --show-current)
$status = (& git -C $rootPath status --short)
if ($status) {
  [ordered]@{
    status = 'blocked'
    reason = 'Working tree is not clean.'
    branch = $branch
    dirty = @($status)
  } | ConvertTo-Json -Depth 6
  exit 0
}

if (-not $SkipPull.IsPresent) {
  & git -C $rootPath pull --ff-only | Out-Null
}

$validation = & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath 'scripts\validate-plugin.ps1')
[ordered]@{
  status = 'updated'
  branch = $branch
  validation = @($validation)
} | ConvertTo-Json -Depth 6
