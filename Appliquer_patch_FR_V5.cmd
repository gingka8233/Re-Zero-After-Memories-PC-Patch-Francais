@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Appliquer_patch_FR_V5.ps1" -SourceExe "%~1"
echo.
if errorlevel 1 (
  echo Le patch a rencontre une erreur. Consulte le message ci-dessus.
) else (
  echo Patch termine.
)
pause
