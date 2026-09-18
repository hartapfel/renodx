$ErrorActionPreference = 'Stop'
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
  cmake --preset clang-x64
  if ($LASTEXITCODE -ne 0) { throw 'DLAA helper configuration failed.' }
  cmake --build --preset clang-x64-release
  if ($LASTEXITCODE -ne 0) { throw 'DLAA helper build failed.' }
} finally { Pop-Location }
