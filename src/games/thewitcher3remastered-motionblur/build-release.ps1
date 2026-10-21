<#
.SYNOPSIS
Builds Motion Blur - Remastered using the established Clang x64 Release preset.
.EXAMPLE
./src/games/thewitcher3remastered-motionblur/build-release.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
if (Get-Process witcher3 -ErrorAction SilentlyContinue) {
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
  cmake --build --preset clang-x64-release --target thewitcher3remastered-motionblur
  if ($LASTEXITCODE -ne 0) { throw 'Motion Blur Release build failed.' }
  if (-not (Test-Path -LiteralPath 'build/Release/renodx-thewitcher3remastered-motionblur.addon64' -PathType Leaf)) {
    throw 'Build finished without producing the Release addon.'
  }
} finally { Pop-Location }
Write-Host "Release addon ready: $(Join-Path $repoRoot 'build/Release/renodx-thewitcher3remastered-motionblur.addon64')"
