# Deploy only the signed FG runtime; the existing DX11 SR runtime is separate.
param([Parameter(Mandatory=$true)][string]$GameDirectory)
$ErrorActionPreference = 'Stop'
$game = (Resolve-Path -LiteralPath $GameDirectory).Path
if (-not (Test-Path -LiteralPath (Join-Path $game 'witcher3.exe'))) { throw 'Expected the Classic executable directory.' }
if (Get-Process witcher3 -ErrorAction SilentlyContinue) { throw 'Close the game before deploying.' }
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
$source = Join-Path $repo 'bin/streamline-2.14.16/bin/x64'
$target = Join-Path $game 'renodx-frame-generation'
$files = @('sl.interposer.dll','sl.common.dll','sl.dlss_g.dll','sl.reflex.dll','sl.pcl.dll','nvngx_dlssg.dll')
foreach ($file in $files) {
    $signature = Get-AuthenticodeSignature -LiteralPath (Join-Path $source $file)
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'NVIDIA') { throw "Invalid NVIDIA signature: $file" }
}
New-Item -ItemType Directory -Force -Path $target | Out-Null
foreach ($file in $files) {
    Copy-Item -LiteralPath (Join-Path $source $file) -Destination (Join-Path $target $file) -Force
    if ((Get-FileHash -LiteralPath (Join-Path $source $file)).Hash -ne (Get-FileHash -LiteralPath (Join-Path $target $file)).Hash) { throw "Deployment verification failed: $file" }
}
Write-Output "Verified six NVIDIA runtime files at $target"
