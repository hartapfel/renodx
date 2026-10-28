# Install an unmodified, already extracted official Streamline 2.14.16 SDK.
# Does not replace external/Streamline or copy DLLs into the running game.
param([Parameter(Mandatory=$true)][string]$SdkDirectory)
$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $SdkDirectory).Path
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
$target = Join-Path $repo 'bin/streamline-2.14.16'
$version = Get-Content -LiteralPath (Join-Path $source 'include/sl_version.h') -Raw
if ($version -notmatch 'SL_VERSION_MAJOR\s+2\b' -or $version -notmatch 'SL_VERSION_MINOR\s+14\b' -or $version -notmatch 'SL_VERSION_PATCH\s+16\b') {
    throw 'Expected the official Streamline 2.14.16 SDK.'
}
$files = @('nvngx_dlss.dll','sl.interposer.dll','sl.common.dll','sl.dlss_g.dll','sl.reflex.dll','sl.pcl.dll','nvngx_dlssg.dll')
foreach ($file in $files) {
    $signature = Get-AuthenticodeSignature -LiteralPath (Join-Path $source "bin/x64/$file")
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'NVIDIA') { throw "Invalid NVIDIA signature: $file" }
}
New-Item -ItemType Directory -Force -Path (Join-Path $target 'include'), (Join-Path $target 'bin/x64') | Out-Null
Copy-Item -Path (Join-Path $source 'include/*') -Destination (Join-Path $target 'include') -Recurse -Force
foreach ($file in $files) { Copy-Item -LiteralPath (Join-Path $source "bin/x64/$file") -Destination (Join-Path $target "bin/x64/$file") -Force }
foreach ($file in @('license.txt','3rd-party-licenses.md','bin/x64/nvngx_dlss.license.txt','bin/x64/reflex.license.txt')) {
    Copy-Item -LiteralPath (Join-Path $source $file) -Destination (Join-Path $target $file) -Force
}
Write-Output "Installed signed SDK at $target"
