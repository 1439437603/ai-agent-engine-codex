param(
  [string]$PluginName = 'ai-agent-engine-codex',
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

$marketplacePluginPath = Join-Path $MarketplaceRoot "plugins\$PluginName"
$cachePluginPath = Join-Path $CacheRoot "ae-local\$PluginName"
Assert-ChildPath $marketplacePluginPath $MarketplaceRoot
Assert-ChildPath $cachePluginPath $CacheRoot

function Remove-RegistrationArtifacts {
  if (Test-Path -LiteralPath $marketplacePluginPath) {
    Remove-Item -LiteralPath $marketplacePluginPath -Recurse -Force
  }
  if (Test-Path -LiteralPath $cachePluginPath) {
    Remove-Item -LiteralPath $cachePluginPath -Recurse -Force
  }
}

if (-not (Test-Path -LiteralPath $MarketplacePath)) {
  Remove-RegistrationArtifacts
  [ordered]@{
    status = 'not_found'
    pluginName = $PluginName
    marketplacePath = $MarketplacePath
    marketplaceRoot = $MarketplaceRoot
    backupPath = $null
    removed = 0
    removedMarketplacePluginPath = $marketplacePluginPath
    removedCachePluginPath = $cachePluginPath
  } | ConvertTo-Json -Depth 5
  exit 0
}

$backupPath = "$MarketplacePath.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -LiteralPath $MarketplacePath -Destination $backupPath -Force
$marketplace = Get-Content -Raw -LiteralPath $MarketplacePath | ConvertFrom-Json
$before = @($marketplace.plugins).Count
$remaining = @($marketplace.plugins) | Where-Object { [string]$_.name -ne $PluginName }
$marketplace.plugins = @($remaining)
$after = @($marketplace.plugins).Count
Write-JsonFile $MarketplacePath $marketplace
Remove-RegistrationArtifacts

[ordered]@{
  status = if ($after -lt $before) { 'unregistered' } else { 'unchanged' }
  pluginName = $PluginName
  marketplacePath = $MarketplacePath
  marketplaceRoot = $MarketplaceRoot
  backupPath = $backupPath
  removed = ($before - $after)
  removedMarketplacePluginPath = $marketplacePluginPath
  removedCachePluginPath = $cachePluginPath
} | ConvertTo-Json -Depth 5
