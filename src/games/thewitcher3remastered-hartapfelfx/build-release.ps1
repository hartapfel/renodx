<#
.SYNOPSIS
Builds The Witcher 3 Remastered - HartapfelFX using the established Clang x64 Release preset.
.EXAMPLE
./src/games/thewitcher3remastered-hartapfelfx/build-release.ps1
#>
[CmdletBinding()]
param([switch]$CompileOnly, [string]$NativeCapturePath, [string]$D3D12SdkPath)

$ErrorActionPreference = 'Stop'
if (-not $CompileOnly -and (Get-Process witcher3 -ErrorAction SilentlyContinue | Where-Object { $_.Modules.ModuleName -contains 'renodx-thewitcher3remastered-hartapfelfx.addon64' })) {
  throw 'Close Witcher 3 before rebuilding its loaded addon.'
}
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (-not (Test-Path -LiteralPath $vswhere -PathType Leaf)) { throw 'Visual Studio Build Tools were not found.' }
$vsPath = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vsPath) { throw 'Install Visual Studio Build Tools with the C++ workload.' }
$devCmd = Join-Path $vsPath 'Common7/Tools/VsDevCmd.bat'
$devEnvironment = & $env:ComSpec /d /c ('"{0}" -no_logo -arch=x64 -host_arch=x64 && set' -f $devCmd)
if ($LASTEXITCODE -ne 0) { throw 'Could not initialise the Visual Studio build environment.' }
foreach ($line in $devEnvironment) {
  if ($line -match '^(PATH|INCLUDE|LIB|LIBPATH|WindowsSdkDir|WindowsSDKVersion|VCToolsInstallDir|VCINSTALLDIR|VisualStudioVersion|VSCMD_ARG_TGT_ARCH)=(.*)$') {
    Set-Item -LiteralPath ('Env:' + $Matches[1]) -Value $Matches[2]
  }
}
# Prefer Visual Studio's bundled LLVM, matching the established local build.
$llvmBin = Join-Path $vsPath 'VC/Tools/Llvm/x64/bin'
if (-not (Test-Path -LiteralPath (Join-Path $llvmBin 'clang-cl.exe') -PathType Leaf)) {
  $llvmBin = Join-Path $env:ProgramFiles 'LLVM/bin'
}
if (Test-Path -LiteralPath (Join-Path $llvmBin 'clang-cl.exe') -PathType Leaf) {
  $env:PATH = $llvmBin + ';' + $env:PATH
}
foreach ($tool in @('cmake', 'ninja', 'clang-cl')) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Required build tool not found: $tool" }
}
Push-Location -LiteralPath $repoRoot
try {
  cmake --preset clang-x64
  if ($LASTEXITCODE -ne 0) { throw 'Clang x64 configuration failed.' }
  if ($CompileOnly) {
    cmake --build --preset clang-x64-release --target thewitcher3remastered-hartapfelfx-shaders
    if ($LASTEXITCODE -ne 0) { throw 'HartapfelFX Release shader build failed.' }
    cmake --build --preset clang-x64-release --target 'CMakeFiles/thewitcher3remastered-hartapfelfx.dir/Release/src/games/thewitcher3remastered-hartapfelfx/addon.cpp.obj'
  } else {
    cmake --build --preset clang-x64-release --target thewitcher3remastered-hartapfelfx
  }
  if ($LASTEXITCODE -ne 0) { throw 'HartapfelFX Release build failed.' }
  & (Join-Path $PSScriptRoot 'tests/source_layout.ps1')
  $validationDirectory = Join-Path $repoRoot 'tmp/hartapfelfx-validation'
  New-Item -ItemType Directory -Path $validationDirectory -Force | Out-Null
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX /Iexternal/reshade (Join-Path $PSScriptRoot 'tests/binding_layout.cpp') ('/Fe' + (Join-Path $validationDirectory 'binding-layout.exe')) ('/Fo' + (Join-Path $validationDirectory 'binding-layout.obj'))
  if ($LASTEXITCODE -ne 0) { throw 'Binding regression test compilation failed.' }
  & (Join-Path $validationDirectory 'binding-layout.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Binding regression test failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX /DWIN32=1 /DImTextureID=ImU64 /Iexternal/reshade (Join-Path $PSScriptRoot 'tests/settings_ui.cpp') external/reshade/deps/imgui/imgui.cpp external/reshade/deps/imgui/imgui_draw.cpp external/reshade/deps/imgui/imgui_tables.cpp external/reshade/deps/imgui/imgui_widgets.cpp ('/Fe' + (Join-Path $validationDirectory 'settings-ui.exe')) ('/Fo' + $validationDirectory + '/') /link user32.lib shell32.lib
  if ($LASTEXITCODE -ne 0) { throw 'Settings UI regression test compilation failed.' }
  & (Join-Path $validationDirectory 'settings-ui.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Settings UI regression test failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX /DWIN32=1 /Iexternal/reshade /Iexternal/gtl/include (Join-Path $PSScriptRoot 'tests/descriptor_cache.cpp') ('/Fe' + (Join-Path $validationDirectory 'descriptor-cache.exe')) ('/Fo' + (Join-Path $validationDirectory 'descriptor-cache.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'Descriptor concurrency test compilation failed.' }
  & (Join-Path $validationDirectory 'descriptor-cache.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Descriptor concurrency test failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /UNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/upload_pool.cpp') ('/Fe' + (Join-Path $validationDirectory 'upload-pool.exe')) ('/Fo' + (Join-Path $validationDirectory 'upload-pool.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'Upload lifetime test compilation failed.' }
  & (Join-Path $validationDirectory 'upload-pool.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Upload lifetime test failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/grid_gpu.cpp') ('/Fe' + (Join-Path $validationDirectory 'grid-gpu.exe')) ('/Fo' + (Join-Path $validationDirectory 'grid-gpu.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'GPU validation compilation failed.' }
  $hostOptions=@()
  if($D3D12SdkPath) {
    $sdkVersion=(Get-Item -LiteralPath (Join-Path $D3D12SdkPath 'D3D12Core.dll')).VersionInfo.FileMinorPart
    $hostOptions+=('/DHARTAPFELFX_TEST_AGILITY='+$sdkVersion)
  }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX /Iexternal/reshade /Iexternal/DLSS/NVIDIAImageScaling/samples/third_party/DXC/inc @hostOptions (Join-Path $PSScriptRoot 'tests/startup_gpu.cpp') ('/Fe' + (Join-Path $validationDirectory 'startup-gpu.exe')) ('/Fo' + (Join-Path $validationDirectory 'startup-gpu.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'Addon compatibility host compilation failed.' }
  & ./bin/dxc.exe -T cs_6_6 -E main -HV 2021 -Ges -WX -Fo (Join-Path $validationDirectory 'features.cso') (Join-Path $PSScriptRoot 'tests/features.cs.hlsl')
  if ($LASTEXITCODE -ne 0) { throw 'GPU feature validation shader compilation failed.' }
  & ./bin/dxc.exe -T ps_6_6 -E main -HV 2021 -Ges -WX -Fo (Join-Path $validationDirectory 'runtime-probe.cso') (Join-Path $PSScriptRoot 'tests/runtime.ps.hlsl')
  if ($LASTEXITCODE -ne 0) { throw 'Runtime validation shader compilation failed.' }
  & (Join-Path $validationDirectory 'grid-gpu.exe') 'build/thewitcher3remastered-hartapfelfx.include/embed' (Join-Path $validationDirectory 'features.cso')
  if ($LASTEXITCODE -ne 0) { throw 'GPU volume validation failed.' }
  foreach ($shader in Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File -Filter '0x*.hlsl') {
    if ($shader.Name -match '\.((?:ps|vs|cs)_6_[36])\.hlsl$') {
      & ./bin/dxc.exe -T $Matches[1] -E main -HV 2021 -Ges -WX -enable-16bit-types -Fo (Join-Path $validationDirectory ($shader.BaseName + '.strict.cso')) $shader.FullName
      if ($LASTEXITCODE -ne 0) { throw "Strict DXIL compilation failed: $($shader.Name)" }
    }
  }
  $cloudDirectory = Join-Path $validationDirectory 'clouds'
  New-Item -ItemType Directory -Path $cloudDirectory -Force | Out-Null
  Copy-Item -Path 'build/thewitcher3remastered-hartapfelfx.include/embed/0xF7C*.cso' -Destination $cloudDirectory
  Copy-Item -LiteralPath 'build/thewitcher3remastered-hartapfelfx.include/embed/0xF7F00001.cso' -Destination $cloudDirectory
  foreach($skyHash in @('449D3390','3B15DAAB')) {
    Copy-Item -LiteralPath ('build/thewitcher3remastered-hartapfelfx.include/embed/0x'+$skyHash+'.cso') -Destination (Join-Path $cloudDirectory ($skyHash+'.cso'))
  }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/clouds_gpu.cpp') ('/Fe' + (Join-Path $validationDirectory 'clouds-gpu.exe')) ('/Fo' + (Join-Path $validationDirectory 'clouds-gpu.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'Cloud GPU validation compilation failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/ray_state.cpp') ('/Fe' + (Join-Path $validationDirectory 'ray-state.exe')) ('/Fo' + (Join-Path $validationDirectory 'ray-state.obj'))
  if ($LASTEXITCODE -ne 0) { throw 'Ray-state validation compilation failed.' }
  & (Join-Path $validationDirectory 'ray-state.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Ray-state graph validation failed.' }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /UNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/cloud_families.cpp') ('/Fe' + (Join-Path $validationDirectory 'cloud-families.exe')) ('/Fo' + (Join-Path $validationDirectory 'cloud-families.obj'))
  if ($LASTEXITCODE -ne 0) { throw 'Cloud family selector compilation failed.' }
  & (Join-Path $validationDirectory 'cloud-families.exe')
  if ($LASTEXITCODE -ne 0) { throw 'Cloud family selector validation failed.' }
  foreach ($shader in @(@('ps_6_6','sky.cso','tests/sky.ps.hlsl'), @('vs_6_6','sky-vs.cso','tests/sky.vs.hlsl'), @('ps_6_6','local-cloud.cso','tests/local_cloud.ps.hlsl'), @('ps_6_6','cloud-depth.cso','tests/cloud_depth.ps.hlsl'), @('cs_6_6','cloud-features.cso','tests/cloud_features.cs.hlsl'), @('ps_6_6','cloud-state.cso','tests/cloud_state.ps.hlsl'), @('cs_6_6','cloud-indirect.cso','tests/cloud_indirect.cs.hlsl'), @('cs_6_6','lighting-controls.cso','tests/lighting_controls.cs.hlsl'), @('lib_6_6','cloud-ray.cso','tests/cloud_ray.lib.hlsl'), @('cs_6_6','motion-9f.cso','0x9F1C32F1.cs_6_6.hlsl'), @('cs_6_6','motion-fa.cso','0xFA11F41B.cs_6_6.hlsl'))) {
    & ./bin/dxc.exe -T $shader[0] -HV 2021 -Ges -WX -Fo (Join-Path $cloudDirectory $shader[1]) (Join-Path $PSScriptRoot $shader[2])
    if ($LASTEXITCODE -ne 0) { throw "Cloud validation shader compilation failed $($shader[2])" }
  }
  & clang-cl /nologo /EHsc /std:c++20 /O2 /UNDEBUG /DNOMINMAX (Join-Path $PSScriptRoot 'tests/local_cloud_gpu.cpp') ('/Fe' + (Join-Path $validationDirectory 'local-cloud-gpu.exe')) ('/Fo' + (Join-Path $validationDirectory 'local-cloud-gpu.obj')) /link d3d12.lib dxgi.lib
  if ($LASTEXITCODE -ne 0) { throw 'Local cloud volume test compilation failed.' }
  & (Join-Path $validationDirectory 'local-cloud-gpu.exe') $cloudDirectory
  if ($LASTEXITCODE -ne 0) { throw 'Local cloud volume test failed.' }
  if ($NativeCapturePath) {
    Copy-Item -LiteralPath (Join-Path $NativeCapturePath '0x9F1C32F1.cs_6_6.cso') -Destination (Join-Path $cloudDirectory 'native-9f.cso')
    Copy-Item -LiteralPath (Join-Path $NativeCapturePath '0xFA11F41B.cs_6_6.cso') -Destination (Join-Path $cloudDirectory 'native-fa.cso')
  }
  & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory
  if ($LASTEXITCODE -ne 0) { throw 'Cloud GPU validation failed.' }
  foreach($skyCase in @('capture-celestial-preview-nativeair','capture-celestial-preview-nativeair-night',
      'capture-celestial-preview-nativeair-fp16','capture-celestial-preview-nativeair-night-fp16',
      'capture-celestial-preview-clear-occlusion-mask-fp16',
      'capture-celestial-preview-clear-occlusion-mask-largebody-fp16',
      'capture-celestial-preview-clear-night-occlusion-mask-fp16',
      'capture-celestial-clear-captured-night-native-sky-standard-haze200-fp16',
      'capture-celestial-clear-captured-night-native-sky-toussaint-haze200-fp16',
      'capture-celestial-preview-clear-night-native-material-fp16',
      'capture-celestial-preview-clear-night-native-material-toussaint-fp16',
      'capture-celestial-preview-clear-nativeair-sunset-fp16',
      'capture-celestial-preview-clear-nativeair-twilight-fp16',
      'capture-celestial-preview-clear-native-solar-material-fp16',
      'capture-celestial-preview-clear-night-phase-waxing-fp16',
      'capture-celestial-preview-clear-night-phase-waning-fp16',
      'capture-celestial-preview-clear-night-phase-new-fp16')) {
    & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory $skyCase (Join-Path $validationDirectory ($skyCase+'.rgba32f'))
    if($LASTEXITCODE -ne 0){throw "Celestial cloud integration failed: $skyCase"}
  }
  # The native fair-weather air coefficients exposed HDR sun leakage through
  # an otherwise dense cloud when the entire sky was treated as foreground air.
  & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory 'capture-horizon-nativeair-sun' (Join-Path $validationDirectory 'nativeair-sun.rgba32f')
  if ($LASTEXITCODE -ne 0) { throw 'Native-air cloud/sun integration failed.' }
  & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory 'capture-horizon-rainair-sun' (Join-Path $validationDirectory 'rainair-sun.rgba32f')
  if ($LASTEXITCODE -ne 0) { throw 'Rainy native-air cloud/sun integration failed.' }
  & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory 'capture-horizon-nativeair-moon-user' (Join-Path $validationDirectory 'nativeair-moon.rgba32f')
  if ($LASTEXITCODE -ne 0) { throw 'Native-air cloud/moon integration failed.' }
  & (Join-Path $validationDirectory 'clouds-gpu.exe') $cloudDirectory 'capture-horizon-nativeair-moon-sun-user' (Join-Path $validationDirectory 'nativeair-moon-sun.rgba32f')
  if ($LASTEXITCODE -ne 0) { throw 'Combined native moon/sun integration failed.' }
  if (-not $CompileOnly -and -not (Test-Path -LiteralPath 'build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64' -PathType Leaf)) {
    throw 'Build finished without producing the Release addon.'
  }
} finally { Pop-Location }
if ($CompileOnly) { Write-Host 'Release C++ object and shader checks passed; loaded addon has not been replaced.' }
else { Write-Host "Release addon ready: $(Join-Path $repoRoot 'build/Release/renodx-thewitcher3remastered-hartapfelfx.addon64')" }
