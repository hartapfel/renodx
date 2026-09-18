param([string]$StreamlineSdkDirectory)
$ErrorActionPreference = 'Stop'
if (Get-Process ACBSP,renodx-asscreedbrotherhood-dx12 -ErrorAction SilentlyContinue) {
  throw 'Close Brotherhood and its DX12 helper before rebuilding linked outputs.'
}
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$visualStudio = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (!$visualStudio) { throw 'Visual Studio C++ build tools are required.' }
$devCommand = '"' + (Join-Path $visualStudio 'Common7/Tools/VsDevCmd.bat') + '" -no_logo -arch=x64 -host_arch=x64 && set'
foreach ($line in (& cmd.exe /d /c $devCommand)) {
  if ($line -match '^(PATH|INCLUDE|LIB|LIBPATH|WindowsSdkDir|WindowsSDKVersion|VCToolsInstallDir|VCINSTALLDIR|VisualStudioVersion|VSCMD_ARG_TGT_ARCH)=(.*)$') {
    Set-Item -LiteralPath ('Env:' + $Matches[1]) -Value $Matches[2]
  }
}
$env:PATH = (Join-Path $visualStudio 'VC/Tools/Llvm/x64/bin') + ';' + $env:PATH
Push-Location $PSScriptRoot
try {
  $sdkOptions = @()
  if ($StreamlineSdkDirectory) {
    $sdkOptions += '-DFETCHCONTENT_SOURCE_DIR_STREAMLINE_SDK=' + (Resolve-Path -LiteralPath $StreamlineSdkDirectory).Path
  }
  cmake --preset clang-x64 @sdkOptions
  if ($LASTEXITCODE -ne 0) { throw 'DX12 presenter configuration failed.' }
  cmake --build --preset clang-x64-release
  if ($LASTEXITCODE -ne 0) { throw 'DX12 presenter build failed.' }
} finally { Pop-Location }
