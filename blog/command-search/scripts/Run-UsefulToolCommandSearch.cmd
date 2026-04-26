@echo off
setlocal
set "SCRIPT_DIR=%~dp0"
chcp 65001 >nul
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Find-UsefulToolCommand.ps1" %*
