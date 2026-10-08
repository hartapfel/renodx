@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0package-release.ps1" %*
set "PACKAGE_EXIT_CODE=%ERRORLEVEL%"
echo.
pause
exit /B %PACKAGE_EXIT_CODE%
