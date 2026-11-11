# Copyright (C) 2026 Hartapfel. SPDX-License-Identifier: MIT
# Runs only the isolated D3D12 compatibility host in workspace test directories.
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ReShadePath,
  [Parameter(Mandatory)][string]$HdrAddonPath,
  [Parameter(Mandatory)][string]$NativeCapturePath,
  [string]$RayCapturePath,
  [string]$D3D12SdkPath,
  [string]$AddonPath,
  [ValidateRange(0,200)][int]$WaterMurk=0,
  [ValidateSet(0,1)][int]$FogRendering=1,
  [ValidateRange(0,3)][int]$LightQuality=0,
  [ValidateRange(0,4)][int[]]$CloudQualityPresets=@(0),
  [ValidateRange(0,5)][int[]]$FogQualityPresets=@(0)
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
  $testDirectory=Join-Path $repoRoot "tmp/hartapfelfx-validation/startup-$order-fog$FogRendering-light$LightQuality-nodevkit"
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
  $expectedAddons=@($(if($fogFirst){'00-hartapfelfx.addon64'}else{'99-hartapfelfx.addon64'}),$(if($fogFirst){'99-hdr.addon64'}else{'00-hdr.addon64'}))
  foreach($extra in Get-ChildItem -LiteralPath $testDirectory -File | Where-Object {$_.Extension -in '.addon','.addon64'}) {
    if($extra.Name -notin $expectedAddons){throw "Unexpected addon in isolated host: $($extra.FullName)"}
  }
  Push-Location -LiteralPath $testDirectory
  try {
    foreach ($cloudQuality in $CloudQualityPresets) {
      foreach($fogPreset in $FogQualityPresets) {
        foreach ($quality in $(if($fogPreset){@(0)}else{@(0,1)})) {
          # Workspace-only profiles exercise the selected presets with the actual addon.
          Set-Content -LiteralPath 'ReShade.ini' -Value "[thewitcher3remastered-hartapfelfx-preset1]`nFogEnabled=$FogRendering`nFogDensity=100`nFogStart=0`nFogQuality=$quality`nFogQualityPresetV1=$fogPreset`nVolumeLightEnabledV1=1`nVolumeLightQualityV1=$LightQuality`nCloudQualityPresetV1=$cloudQuality`nSunDiameter=1.3`nWaterMurkV1=$WaterMurk" -Encoding ascii
          Write-Host "Checking $order, fog quality $quality, fog preset $fogPreset, cloud preset $cloudQuality"
          $columns=if($fogPreset){@(0,120,160,240,256,256)[$fogPreset]}elseif($quality){240}else{160}
          $lightColumns=@(120,160,240,256)[$LightQuality]
          $columns=if($FogRendering){[Math]::Max($columns,$lightColumns)}else{$lightColumns}
          & ./startup-gpu.exe $NativeCapturePath $embedPath (Join-Path $repoRoot 'tmp/hartapfelfx-validation/runtime-probe.cso') $columns @cloudArguments
          if($LASTEXITCODE -ne 0){throw "Addon compatibility failed in $order order at fog $quality / preset $fogPreset / cloud $cloudQuality (exit $LASTEXITCODE)"}
        }
      }
    }
  }finally{Pop-Location}
}
