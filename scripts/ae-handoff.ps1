param(
  [string]$Root = (Get-Location).Path,
  [Parameter(Mandatory = $true)]
  [string]$Title,
  [Parameter(Mandatory = $true)]
  [string]$Goal,
  [string]$Status = 'running',
  [string]$Evidence = '',
  [string]$NextStep = ''
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$dir = Join-Path $rootPath 'docs\ae\handoffs'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$slug = ($Title.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
if ([string]::IsNullOrWhiteSpace($slug)) { $slug = 'handoff' }
$path = Join-Path $dir "$(Get-Date -Format 'yyyy-MM-dd-HHmmss')-$slug.md"

$body = @"
---
status: $Status
generated_by: ae:handoff
---

# $Title

## Goal
$Goal

## Current Status
$Status

## Evidence
$Evidence

## Unfinished Work
$NextStep

## Restore Instructions
Read this file, verify the current repository state, then continue from the unfinished work section.
"@
$body | Set-Content -Encoding UTF8 -LiteralPath $path

[ordered]@{
  status = 'written'
  path = ($path.Substring($rootPath.Length).TrimStart('\', '/') -replace '\\', '/')
} | ConvertTo-Json -Depth 5
