param(
  [string]$PluginRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$MarketplaceRoot = (Join-Path $env:USERPROFILE '.codex\local-marketplaces\ae-codex'),
  [string]$MarketplacePath,
  [string]$CacheRoot = (Join-Path $env:USERPROFILE '.codex\plugins\cache')
)

$ErrorActionPreference = 'Stop'

function Get-FullPath($path) {
  return [System.IO.Path]::GetFullPath($path)
}

function Assert-ChildPath($childPath, $parentPath) {
  $childFull = (Get-FullPath $childPath)
  $parentFull = (Get-FullPath $parentPath).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
  $comparison = [System.StringComparison]::OrdinalIgnoreCase
  if (-not $childFull.StartsWith($parentFull + [System.IO.Path]::DirectorySeparatorChar, $comparison)) {
    throw "Refusing to modify path outside expected root. Path: $childFull Root: $parentFull"
  }
}

function Write-JsonFile($path, $value) {
  $json = $value | ConvertTo-Json -Depth 10
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $json, $utf8NoBom)
}

$pluginRootPath = (Resolve-Path -LiteralPath $PluginRoot).Path
$manifestPath = Join-Path $pluginRootPath '.codex-plugin\plugin.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
  throw "Missing plugin manifest: $manifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
if ([string]::IsNullOrWhiteSpace($MarketplacePath)) {
  $MarketplacePath = Join-Path $MarketplaceRoot '.agents\plugins\marketplace.json'
} elseif (-not $PSBoundParameters.ContainsKey('MarketplaceRoot')) {
  $marketplaceFile = Get-FullPath $MarketplacePath
  $pluginsDir = Split-Path -Parent $marketplaceFile
  $agentsDir = Split-Path -Parent $pluginsDir
  if ((Split-Path -Leaf $pluginsDir) -eq 'plugins' -and (Split-Path -Leaf $agentsDir) -eq '.agents') {
    $MarketplaceRoot = Split-Path -Parent $agentsDir
  } else {
    $MarketplaceRoot = Split-Path -Parent $marketplaceFile
  }
}
$marketplaceDir = Split-Path -Parent $MarketplacePath
New-Item -ItemType Directory -Force -Path $marketplaceDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $MarketplaceRoot 'plugins') | Out-Null

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
    path = "./plugins/$($manifest.name)"
  }
  policy = [pscustomobject]@{
    installation = 'AVAILABLE'
    authentication = 'ON_INSTALL'
  }
  category = 'Coding'
}
$marketplace.plugins = @($plugins + $entry)
Write-JsonFile $MarketplacePath $marketplace

$marketplacePluginPath = Join-Path $MarketplaceRoot "plugins\$($manifest.name)"
Assert-ChildPath $marketplacePluginPath $MarketplaceRoot
if (Test-Path -LiteralPath $marketplacePluginPath) {
  Remove-Item -LiteralPath $marketplacePluginPath -Recurse -Force
}
Copy-Item -LiteralPath $pluginRootPath -Destination $marketplacePluginPath -Recurse -Force
Remove-Item -LiteralPath (Join-Path $marketplacePluginPath '.git') -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $marketplacePluginPath '.omx') -Recurse -Force -ErrorAction SilentlyContinue

$cachePluginPath = Join-Path $CacheRoot "ae-local\$($manifest.name)\$($manifest.version)"
Assert-ChildPath $cachePluginPath $CacheRoot
if (Test-Path -LiteralPath $cachePluginPath) {
  Remove-Item -LiteralPath $cachePluginPath -Recurse -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $cachePluginPath) | Out-Null
Copy-Item -LiteralPath $pluginRootPath -Destination $cachePluginPath -Recurse -Force
Remove-Item -LiteralPath (Join-Path $cachePluginPath '.git') -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $cachePluginPath '.omx') -Recurse -Force -ErrorAction SilentlyContinue

[ordered]@{
  status = 'registered'
  pluginName = $manifest.name
  version = $manifest.version
  marketplacePath = $MarketplacePath
  marketplaceRoot = $MarketplaceRoot
  backupPath = $backupPath
  pluginPath = $pluginRootPath
  marketplacePluginPath = $marketplacePluginPath
  cachePluginPath = $cachePluginPath
} | ConvertTo-Json -Depth 5
