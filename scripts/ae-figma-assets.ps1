param(
  [Parameter(Mandatory = $true)]
  [string]$SourcePath,
  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourcePath)) {
  throw "SourcePath does not exist: $SourcePath"
}
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

[ordered]@{
  status = 'collected'
  sourcePath = (Resolve-Path -LiteralPath $SourcePath).Path
  outputPath = (Resolve-Path -LiteralPath $OutputPath).Path
  apiExportEnabled = $false
  note = 'Planned development: only authorized local asset collection is enabled; Figma API export requires explicit token design.'
} | ConvertTo-Json -Depth 5
