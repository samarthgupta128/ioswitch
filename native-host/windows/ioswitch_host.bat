@echo off
:: IO Switch Native Messaging Host
:: This script receives messages from Firefox and opens URLs in the default browser

:: Read the message length (4 bytes) - we'll skip this for simplicity
:: and just read the JSON message

:: Use PowerShell to handle the native messaging protocol
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ioswitch_host.ps1"
