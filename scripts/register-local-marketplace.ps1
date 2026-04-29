param(
  [string]$PluginRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$MarketplacePath = (Join-Path $env:USERPROFILE '.agents\plugins\marketplace.json')
)

$ErrorActionPreference = 'Stop'

function Normalize-PathForJson($path) {
  return ($path -replace '\\', '/')
}

$pluginRootPath = (Resolve-Path -LiteralPath $PluginRoot).Path
$manifestPath = Join-Path $pluginRootPath '.codex-plugin\plugin.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
  throw "Missing plugin manifest: $manifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$marketplaceDir = Split-Path -Parent $MarketplacePath
New-Item -ItemType Directory -Force -Path $marketplaceDir | Out-Null

$backupPath = $null
if (Test-Path -LiteralPath $MarketplacePath) {
  $backupPath = "$MarketplacePath.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
  Copy-Item -LiteralPath $MarketplacePath -Destination $backupPath -Force
  $marketplace = Get-Content -Raw -LiteralPath $MarketplacePath | ConvertFrom-Json
} else {
  $marketplace = [pscustomobject]@{
    name = 'local'
    interface = [pscustomobject]@{ displayName = 'Local Plugins' }
    plugins = @()
  }
}

$plugins = @($marketplace.plugins) | Where-Object { $_.name -ne $manifest.name }
$entry = [pscustomobject]@{
  name = $manifest.name
  source = [pscustomobject]@{
    source = 'local'
    path = Normalize-PathForJson $pluginRootPath
  }
  policy = [pscustomobject]@{
    installation = 'AVAILABLE'
    authentication = 'ON_INSTALL'
  }
  category = 'Coding'
}
$marketplace.plugins = @($plugins + $entry)
$marketplace | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 -LiteralPath $MarketplacePath

[ordered]@{
  status = 'registered'
  pluginName = $manifest.name
  marketplacePath = $MarketplacePath
  backupPath = $backupPath
  pluginPath = $pluginRootPath
} | ConvertTo-Json -Depth 5
