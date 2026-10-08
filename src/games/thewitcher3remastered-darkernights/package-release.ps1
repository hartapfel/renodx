<#
.SYNOPSIS
Packages the standalone Release addon with the Witcher 3 game-root ZIP layout.
.EXAMPLE
./src/games/thewitcher3remastered-darkernights/package-release.ps1
.EXAMPLE
./src/games/thewitcher3remastered-darkernights/package-release.ps1 -Build -Version 1.0
#>
[CmdletBinding()]
param(
  [switch]$Build,
  [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
  [string]$Version,
  [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$addonPath = Join-Path $repoRoot 'build/Release/renodx-thewitcher3remastered-darkernights.addon64'
if ($Build) {
  & (Join-Path $PSScriptRoot 'build-release.ps1')
}
if (-not (Test-Path -LiteralPath $addonPath -PathType Leaf)) {
  throw "Release addon missing: $addonPath. Run this script with -Build first."
}
$addon = Get-Item -LiteralPath $addonPath
if ($addon.Length -eq 0) { throw 'The Release addon is empty.' }
if (-not $Version) {
  $Version = $addon.VersionInfo.FileVersion
  if (-not $Version -or $Version -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    $Version = $addon.LastWriteTime.ToString('yyyyMMdd-HHmmss')
  }
}
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $repoRoot 'build/Release/packages' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$zipPath = Join-Path $OutputDirectory "tw3-darkernights-remastered-$Version.zip"
$temporaryZip = Join-Path $OutputDirectory ([Guid]::NewGuid().ToString('N') + '.zip')
$files = [ordered]@{
  'bin/x64_dx12/tw3-darkernights-remastered.addon64' = $addonPath
  'README-Darker-Nights.txt' = Join-Path $PSScriptRoot 'packaging/README.txt'
  'LICENSE.txt' = Join-Path $repoRoot 'LICENSE'
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
  $archive = [IO.Compression.ZipFile]::Open($temporaryZip, [IO.Compression.ZipArchiveMode]::Create)
  try {
    foreach ($name in $files.Keys) {
      [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $archive, $files[$name], $name, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
  } finally { $archive.Dispose() }
  # Check the archive itself, including the renamed DLL's decompressed bytes.
  $archive = [IO.Compression.ZipFile]::OpenRead($temporaryZip)
  try {
    if ($archive.Entries.Count -ne $files.Count) { throw 'Unexpected ZIP contents.' }
    foreach ($name in $files.Keys) {
      $entry = $archive.GetEntry($name)
      if (-not $entry) { throw "ZIP entry missing: $name" }
      $stream = $entry.Open()
      $sourceStream = [IO.File]::OpenRead($files[$name])
      $sha256 = [Security.Cryptography.SHA256]::Create()
      try {
        $hash = [BitConverter]::ToString($sha256.ComputeHash($stream))
        $sourceHash = [BitConverter]::ToString($sha256.ComputeHash($sourceStream))
      } finally { $stream.Dispose(); $sourceStream.Dispose(); $sha256.Dispose() }
      if ($hash -ne $sourceHash) {
        throw "ZIP content verification failed: $name"
      }
    }
  } finally { $archive.Dispose() }
  Move-Item -LiteralPath $temporaryZip -Destination $zipPath -Force
} finally {
  if (Test-Path -LiteralPath $temporaryZip) { Remove-Item -LiteralPath $temporaryZip }
}
Write-Host "Packaged and verified: $zipPath"
Write-Host 'Addon: bin/x64_dx12/tw3-darkernights-remastered.addon64'
Write-Host 'Extract this ZIP into the game root.'
Get-Item -LiteralPath $zipPath
