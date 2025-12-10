@echo off
:: IO Switch - Native Messaging Host Installer
:: Run this script as Administrator to install the native messaging host

echo ============================================
echo   IO Switch - Native Host Installer
echo ============================================
echo.

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script requires Administrator privileges.
    echo Please right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: Set variables
set "INSTALL_DIR=C:\ioswitch"
set "SCRIPT_DIR=%~dp0"
set "REG_KEY=HKLM\SOFTWARE\Mozilla\NativeMessagingHosts\ioswitch"

echo Installing to: %INSTALL_DIR%
echo.

:: Create installation directory
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo Created directory: %INSTALL_DIR%
) else (
    echo Directory already exists: %INSTALL_DIR%
)

:: Copy files
echo Copying files...
copy /Y "%SCRIPT_DIR%ioswitch_host.bat" "%INSTALL_DIR%\" >nul
copy /Y "%SCRIPT_DIR%ioswitch_host.ps1" "%INSTALL_DIR%\" >nul
copy /Y "%SCRIPT_DIR%ioswitch.json" "%INSTALL_DIR%\" >nul
echo Files copied successfully.

:: Update the JSON file with correct path
echo Updating manifest path...
powershell -NoProfile -Command "(Get-Content '%INSTALL_DIR%\ioswitch.json') -replace 'C:\\\\ioswitch\\\\ioswitch_host.bat', '%INSTALL_DIR:\=\\%\\ioswitch_host.bat' | Set-Content '%INSTALL_DIR%\ioswitch.json'"

:: Register with Firefox (system-wide)
echo Registering with Firefox...
reg add "%REG_KEY%" /ve /t REG_SZ /d "%INSTALL_DIR%\ioswitch.json" /f >nul

if %errorLevel% equ 0 (
    echo.
    echo ============================================
    echo   Installation Complete!
    echo ============================================
    echo.
    echo The native messaging host has been installed.
    echo.
    echo Next steps:
    echo 1. Load the extension in Firefox (about:debugging)
    echo 2. Restart Firefox
    echo 3. Click the IO Switch icon to configure domains
    echo.
) else (
    echo.
    echo ERROR: Failed to add registry key.
    echo.
)

pause
