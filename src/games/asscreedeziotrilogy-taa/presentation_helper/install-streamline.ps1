param(
  [Parameter(Mandatory = $true)][string]$SdkDirectory,
  [string]$DestinationDirectory = (Join-Path $PSScriptRoot '../../../../build64-eziotrilogy-dx12/Release/streamline')
)
$ErrorActionPreference = 'Stop'
if (Get-Process ACBSP,renodx-asscreedeziotrilogy-dx12 -ErrorAction SilentlyContinue) {
  throw 'Close Brotherhood and its DX12 helper before updating the runtime.'
}
$sdkPath = (Resolve-Path -LiteralPath $SdkDirectory).Path
$sdkVersion = Get-Content -LiteralPath (Join-Path $sdkPath 'include/sl_version.h') -Raw
if ($sdkVersion -notmatch '#define SL_VERSION_MAJOR 2\s' -or
    $sdkVersion -notmatch '#define SL_VERSION_MINOR 14\s' -or
    $sdkVersion -notmatch '#define SL_VERSION_PATCH 1\s') {
  throw 'Use the official Streamline 2.14.1 SDK matching the DX12 helper headers.'
}
$runtimeFiles = @('sl.interposer.dll','sl.common.dll','sl.dlss.dll','sl.dlss_g.dll','sl.reflex.dll','sl.pcl.dll','nvngx_dlss.dll','nvngx_dlssg.dll')
foreach ($runtimeFile in $runtimeFiles) {
  $signature = Get-AuthenticodeSignature -LiteralPath (Join-Path $sdkPath ('bin/x64/' + $runtimeFile))
  if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'NVIDIA Corporation') {
    throw "Invalid NVIDIA production signature: $runtimeFile"
  }
}
New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
foreach ($runtimeFile in ($runtimeFiles + @('nvngx_dlss.license.txt','reflex.license.txt'))) {
  Copy-Item -LiteralPath (Join-Path $sdkPath ('bin/x64/' + $runtimeFile)) -Destination $DestinationDirectory
}
Copy-Item -LiteralPath (Join-Path $sdkPath 'license.txt') -Destination (Join-Path $DestinationDirectory 'Streamline-LICENSE.txt')
Get-ChildItem -LiteralPath $DestinationDirectory -Filter '*.dll' | Get-FileHash -Algorithm SHA256 |
  Select-Object @{Name='File';Expression={Split-Path -Leaf $_.Path}},Hash |
  ConvertTo-Json | Set-Content -LiteralPath (Join-Path $DestinationDirectory 'runtime-sha256.json')
Write-Output 'Installed the optional NVIDIA production runtime and licenses. Keep this entire directory beside the DX12 helper.'
