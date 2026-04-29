param(
  [string]$PluginName = 'ai-agent-engine-codex',
  [string]$MarketplacePath = (Join-Path $env:USERPROFILE '.agents\plugins\marketplace.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $MarketplacePath)) {
  [ordered]@{
    status = 'not_found'
    pluginName = $PluginName
    marketplacePath = $MarketplacePath
    backupPath = $null
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
$marketplace | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 -LiteralPath $MarketplacePath

[ordered]@{
  status = if ($after -lt $before) { 'unregistered' } else { 'unchanged' }
  pluginName = $PluginName
  marketplacePath = $MarketplacePath
  backupPath = $backupPath
  removed = ($before - $after)
} | ConvertTo-Json -Depth 5
