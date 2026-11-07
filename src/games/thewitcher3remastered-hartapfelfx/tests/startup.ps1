# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
# Runs only the isolated D3D12 compatibility host in workspace test directories.
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ReShadePath,
  [Parameter(Mandatory)][string]$HdrAddonPath,
  [Parameter(Mandatory)][string]$NativeCapturePath,
  [string]$RayCapturePath,
  [string]$D3D12SdkPath,
  [string]$AddonPath
)
$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$hostPath=Join-Path $repoRoot 'tmp/hartapfelfx-validation/startup-gpu.exe'
if(-not $AddonPath){$AddonPath=Join-Path $repoRoot 'build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64'}
$embedPath=Join-Path $repoRoot 'build/thewitcher3remastered-hartapfelfx.include/embed'
foreach($path in @($ReShadePath,$HdrAddonPath,$hostPath,$addonPath)) {
  if(-not (Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing validation input $path"}
}
$ReShadePath=(Resolve-Path -LiteralPath $ReShadePath).Path
$HdrAddonPath=(Resolve-Path -LiteralPath $HdrAddonPath).Path
$NativeCapturePath=(Resolve-Path -LiteralPath $NativeCapturePath).Path
$cloudDirectory=Join-Path $repoRoot 'tmp/hartapfelfx-validation/clouds'
$cloudArguments=@()
if($RayCapturePath){$cloudArguments=@((Resolve-Path -LiteralPath $RayCapturePath).Path,$cloudDirectory)}
foreach($fogFirst in @($false,$true)) {
  $order=if($fogFirst){'fog-first'}else{'hdr-first'}
  $testDirectory=Join-Path $repoRoot "tmp/hartapfelfx-validation/startup-$order"
  New-Item -ItemType Directory -Path $testDirectory -Force | Out-Null
  if($D3D12SdkPath) {
    $sdkDirectory=Join-Path $testDirectory 'D3D12_0'
    New-Item -ItemType Directory -Path $sdkDirectory -Force | Out-Null
    Get-ChildItem -LiteralPath $D3D12SdkPath -Filter '*.dll' -File | Copy-Item -Destination $sdkDirectory
  }
  Copy-Item -LiteralPath $hostPath -Destination (Join-Path $testDirectory 'startup-gpu.exe')
  Copy-Item -LiteralPath (Join-Path $repoRoot 'bin/dxcompiler.dll') -Destination (Join-Path $testDirectory 'dxcompiler.dll')
  Copy-Item -LiteralPath $ReShadePath -Destination (Join-Path $testDirectory 'dxgi.dll')
  # Distinct names and directories make the loader order explicit in ReShade.log.
  Copy-Item -LiteralPath $addonPath -Destination (Join-Path $testDirectory $(if($fogFirst){'00-hartapfelfx.addon64'}else{'99-hartapfelfx.addon64'}))
  Copy-Item -LiteralPath $HdrAddonPath -Destination (Join-Path $testDirectory $(if($fogFirst){'99-hdr.addon64'}else{'00-hdr.addon64'}))
  Push-Location -LiteralPath $testDirectory
  try {
    foreach ($quality in @(0, 1)) {
      # Workspace-only profiles exercise Balanced and High with the actual addon.
      Set-Content -LiteralPath 'ReShade.ini' -Value "[thewitcher3remastered-hartapfelfx-preset1]`nFogQuality=$quality" -Encoding ascii
      & ./startup-gpu.exe $NativeCapturePath $embedPath (Join-Path $repoRoot 'tmp/hartapfelfx-validation/runtime-probe.cso') $(if ($quality) { 240 } else { 160 }) @cloudArguments
      if($LASTEXITCODE -ne 0){throw "Addon compatibility failed in $order order at quality $quality (exit $LASTEXITCODE)"}
    }
  }finally{Pop-Location}
}
