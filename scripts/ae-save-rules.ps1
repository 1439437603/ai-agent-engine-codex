param(
  [string]$Root = (Get-Location).Path,
  [string]$Category = 'general',
  [Parameter(Mandatory = $true)]
  [string]$Content
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$safeCategory = ($Category.ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
if ([string]::IsNullOrWhiteSpace($safeCategory)) { $safeCategory = 'general' }
$dir = Join-Path $rootPath 'docs\ae\rules'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$path = Join-Path $dir "$safeCategory.md"

$body = @"
---
category: $safeCategory
generated_by: ae:save-rules
---

# AE Rule: $safeCategory

$Content
"@
$body | Set-Content -Encoding UTF8 -LiteralPath $path

[ordered]@{
  status = 'saved'
  path = ($path.Substring($rootPath.Length).TrimStart('\', '/') -replace '\\', '/')
  promotedToAgentsMd = $false
} | ConvertTo-Json -Depth 5
