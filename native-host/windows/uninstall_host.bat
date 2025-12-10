@echo off
:: IO Switch - Native Messaging Host Uninstaller
:: Run this script as Administrator to uninstall the native messaging host

echo ============================================
echo   IO Switch - Native Host Uninstaller
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

set "INSTALL_DIR=C:\ioswitch"
set "REG_KEY=HKLM\SOFTWARE\Mozilla\NativeMessagingHosts\ioswitch"

echo Removing registry entry...
reg delete "%REG_KEY%" /f >nul 2>&1

echo Removing installation directory...
if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%"
    echo Removed: %INSTALL_DIR%
) else (
    echo Directory not found: %INSTALL_DIR%
)

echo.
echo ============================================
echo   Uninstallation Complete!
echo ============================================
echo.
echo The native messaging host has been removed.
echo.

pause
