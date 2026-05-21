@echo off
setlocal

:: Self-elevate if not running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting elevation...
    powershell.exe -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Running with Administrator privileges...

set "PowerShellExe=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "ScriptPath=%~dp0relocate-nvidia-shader-cache-wrapper.ps1"
set "ConfigPath=%~dp0relocate-nvidia-shader-cache-wrapper.conf"

set "DXCACHE="
set "GLCACHE="

if exist "%ConfigPath%" (
    for /f "usebackq tokens=1* delims==" %%A in ("%ConfigPath%") do (
        if /i "%%A"=="DXCACHE" set "DXCACHE=%%B"
        if /i "%%A"=="GLCACHE" set "GLCACHE=%%B"
    )
)

if not defined DXCACHE set "DXCACHE=I:\NVIDIAShaderCache\DXCache"
if not defined GLCACHE set "GLCACHE=I:\NVIDIAShaderCache\GLCache"

if not exist "%ScriptPath%" (
    echo ERROR: Could not find PowerShell script: "%ScriptPath%"
    pause
    exit /b 1
)

"%PowerShellExe%" -NoProfile -ExecutionPolicy Bypass -File "%ScriptPath%" -WrapperLaunched -DXCache "%DXCACHE%" -GLCache "%GLCACHE%"

endlocal
exit /b
