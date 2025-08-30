@echo off
setlocal enabledelayedexpansion

set NOTE=%~1
set ROOT=%cd%
set DIARY=%ROOT%\.diary
set ENTRIES=%DIARY%\data\entries

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set DATE=%%i
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HH-mm-ss"') do set TIME=%%i

set ENTRY=%ENTRIES%\%DATE%\%TIME%
powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path '%ENTRY%' | Out-Null"

powershell -NoProfile -ExecutionPolicy Bypass -File "%DIARY%\scripts\capture.ps1" "%NOTE%"

echo Saved entry at %ENTRY%

endlocal

