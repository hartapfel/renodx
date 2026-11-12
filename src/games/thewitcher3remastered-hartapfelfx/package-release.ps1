<#
.SYNOPSIS
Creates a game-root ZIP containing the HartapfelFX addon and local light alignment.
.EXAMPLE
./src/games/thewitcher3remastered-hartapfelfx/package-release.ps1
.EXAMPLE
./src/games/thewitcher3remastered-hartapfelfx/package-release.ps1 -Build -Version 1.0
#>
[CmdletBinding()]
param(
  [switch]$Build,
  [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')][string]$Version,
  [string]$OutputDirectory,
  [string]$AlignmentPackage
)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$addonPath = Join-Path $repoRoot 'build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64'
if ($Build) { & (Join-Path $PSScriptRoot 'build-release.ps1') }
if (-not (Test-Path -LiteralPath $addonPath -PathType Leaf)) {
  throw "Release addon missing: $addonPath. Run with -Build first."
}
$addon = Get-Item -LiteralPath $addonPath
if ($addon.Length -eq 0) { throw 'The Release addon is empty.' }
$newerSource = Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File |
  Where-Object { $_.Extension -in '.cpp','.h','.hpp','.hlsl','.hlsli' -and $_.FullName -notmatch '[\\/]tests[\\/]' -and $_.LastWriteTimeUtc -gt $addon.LastWriteTimeUtc } |
  Select-Object -First 1
if ($newerSource) { throw "Release addon is older than $($newerSource.Name). Rebuild first, or use -Build with the game closed." }
if (-not $Version) { $Version = $addon.LastWriteTime.ToString('yyyyMMdd-HHmmss') }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot 'build/Release/packages' }
if (-not $AlignmentPackage) {
  $AlignmentPackage = Join-Path $repoRoot 'build/Release/packages/HartapfelFX-Light-Alignment-1.1.3/HartapfelFX-Light-Alignment-Remastered-1.1.3.zip'
}
if (-not (Test-Path -LiteralPath $AlignmentPackage -PathType Leaf)) {
  throw "Validated light-alignment ZIP missing: $AlignmentPackage. Supply -AlignmentPackage or build it using lighting/alignment/README.md. Alignment is required and is never silently omitted."
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw 'Packaging requires Python 3 on this development PC. Players do not need Python.' }
$packageArguments = @((Join-Path $PSScriptRoot 'package-release.py'), '--addon', $addonPath,
  '--alignment-package', ([IO.Path]::GetFullPath($AlignmentPackage)), '--output-directory', ([IO.Path]::GetFullPath($OutputDirectory)), '--version', $Version)
& python @packageArguments
if ($LASTEXITCODE -ne 0) { throw 'HartapfelFX packaging failed. See the error above.' }
