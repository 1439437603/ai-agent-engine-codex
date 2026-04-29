param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

function Get-FrontmatterField($text, $field) {
  $match = [regex]::Match($text, "(?m)^$field\s*:\s*(.+)$")
  if (-not $match.Success) { return '' }
  return $match.Groups[1].Value.Trim().Trim('"').Trim("'")
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$skillFiles = Get-ChildItem -Recurse -File -LiteralPath (Join-Path $rootPath 'skills') -Filter 'SKILL.md' |
  Sort-Object FullName
$scriptFiles = Get-ChildItem -File -LiteralPath (Join-Path $rootPath 'scripts') -Filter '*.ps1' |
  Where-Object { $_.Name -notlike 'test-*' } |
  Sort-Object Name

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# AE Codex 帮助') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Skills') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| Skill | 说明 |') | Out-Null
$lines.Add('| --- | --- |') | Out-Null
foreach ($file in $skillFiles) {
  $text = Get-Content -Raw -LiteralPath $file.FullName
  $name = Get-FrontmatterField $text 'name'
  $description = Get-FrontmatterField $text 'description'
  $lines.Add('| `' + $name + '` | ' + $description + ' |') | Out-Null
}
$lines.Add('') | Out-Null
$lines.Add('## Scripts') | Out-Null
$lines.Add('') | Out-Null
foreach ($script in $scriptFiles) {
  $lines.Add('- `' + $script.Name + '`') | Out-Null
}

$lines -join "`n"
