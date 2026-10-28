<#
.SYNOPSIS
Packages the Classic Release addon, production NVIDIA runtimes and licenses.
.EXAMPLE
./src/games/thewitcher3classic/package-release.ps1
.EXAMPLE
./src/games/thewitcher3classic/package-release.ps1 -Build -Version 1.0
#>
[CmdletBinding()]
param(
  [switch]$Build,
  [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
  [string]$Version,
  [string]$OutputDirectory,
  [string]$StreamlineSdk
)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$addonPath = Join-Path $repoRoot 'build/Release/renodx-thewitcher3classic.addon64'
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
$zipPath = Join-Path $OutputDirectory "renodx-witcher3-classic-$Version.zip"
$temporaryZip = Join-Path $OutputDirectory ([Guid]::NewGuid().ToString('N') + '.zip')
if (-not $StreamlineSdk) { $StreamlineSdk = Join-Path $repoRoot 'bin/streamline-2.14.16' }
$StreamlineSdk = [IO.Path]::GetFullPath($StreamlineSdk)
$files = [ordered]@{
  'bin/x64/renodx-thewitcher3classic.addon64' = $addonPath
  'bin/x64/renodx-licenses/RenoDX-LICENSE.txt' = Join-Path $repoRoot 'LICENSE'
  'bin/x64/renodx-licenses/Optics-LICENSE.txt' = Join-Path $PSScriptRoot 'optics/LICENSE.optics'
  'bin/x64/renodx-witcher3classic-dlss/NVIDIA-DLSS-LICENSE.txt' = Join-Path $StreamlineSdk 'bin/x64/nvngx_dlss.license.txt'
  'bin/x64/renodx-frame-generation/NVIDIA-DLSS-LICENSE.txt' = Join-Path $StreamlineSdk 'bin/x64/nvngx_dlss.license.txt'
  'bin/x64/renodx-frame-generation/NVIDIA-Reflex-LICENSE.txt' = Join-Path $StreamlineSdk 'bin/x64/reflex.license.txt'
  'bin/x64/renodx-frame-generation/Streamline-LICENSE.txt' = Join-Path $StreamlineSdk 'license.txt'
  'bin/x64/renodx-frame-generation/Streamline-THIRD-PARTY-LICENSES.md' = Join-Path $StreamlineSdk '3rd-party-licenses.md'
}
foreach ($name in @('nvngx_dlss.dll','sl.interposer.dll','sl.common.dll','sl.dlss_g.dll','sl.reflex.dll','sl.pcl.dll','nvngx_dlssg.dll')) {
  # Use only production binaries, never bin/x64/development.
  $source = Join-Path $StreamlineSdk "bin/x64/$name"
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "NVIDIA runtime missing: $source. Run frame_generation/install-sdk.ps1 with the official 2.14.16 SDK first."
  }
  $signature = Get-AuthenticodeSignature -LiteralPath $source
  if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'NVIDIA') {
    throw "Invalid NVIDIA signature: $name"
  }
  $directory = if ($name -eq 'nvngx_dlss.dll') { 'renodx-witcher3classic-dlss' } else { 'renodx-frame-generation' }
  $files["bin/x64/$directory/$name"] = $source
}
foreach ($source in $files.Values) {
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Package source missing: $source" }
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
  # Check the archive itself, including the DLL's decompressed bytes.
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
$checksumPath = $zipPath + '.sha256'
[IO.File]::WriteAllText($checksumPath,
  (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + [IO.Path]::GetFileName($zipPath) + "`n",
  [Text.Encoding]::ASCII)
Write-Host "Packaged and verified: $zipPath"
Write-Host "SHA256: $checksumPath"
Write-Host 'Addon: bin/x64/renodx-thewitcher3classic.addon64'
Write-Host 'Extract this ZIP into the game root.'
Get-Item -LiteralPath $zipPath
