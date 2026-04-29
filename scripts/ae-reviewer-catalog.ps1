param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$reviewerRoot = Join-Path $rootPath 'references\reviewers'
$reviewers = @()
if (Test-Path -LiteralPath $reviewerRoot) {
  $reviewers = Get-ChildItem -File -LiteralPath $reviewerRoot -Filter '*.md' |
    Sort-Object Name |
    ForEach-Object {
      [pscustomobject]@{
        id = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        path = ($_.FullName.Substring($rootPath.Length).TrimStart('\', '/') -replace '\\', '/')
      }
    }
}

[ordered]@{
  count = @($reviewers).Count
  reviewers = @($reviewers)
} | ConvertTo-Json -Depth 6
