@echo off
setlocal EnableExtensions

:: ============================================================================
:: WinOpti.bat - Final, Optimized & Working Version
::
:: This version maintains the exact script structure proven to work in the
:: restrictive environment, while incorporating clear error messages and
:: enhanced security by removing argument forwarding.
:: ============================================================================

:: --- Configuration ---
set "SCRIPT_PATH=%~dp0"
set "SCRIPT_NAME=%~dpn0.ps1"
set "POWERSHELL=powershell.exe"

:: --- Pre-checks ---

:: 1. Change to script directory
cd /d "%SCRIPT_PATH%" || (
    echo [ERROR] Falha ao mudar para o diretorio do script.
    pause
    exit /b 1
)

:: 2. Check if PowerShell executable exists
where %POWERSHELL% >nul 2>nul || (
    echo [ERROR] Executavel do PowerShell nao encontrado no PATH.
    pause
    exit /b 1
)

:: 3. Check if the target PowerShell script exists
if not exist "%SCRIPT_NAME%" (
    echo [ERROR] O script alvo '%SCRIPT_NAME%' nao foi encontrado.
    pause
    exit /b 1
)

:: --- Argument Preparation & Elevation (Security Hardened) ---
:: Argument forwarding (%*) has been removed to prevent potential injection vulnerabilities.
set "ELEVATED_ARGS=-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_NAME%\""

:: Execute PowerShell to trigger Start-Process with elevation (Original Multi-line Syntax)
%POWERSHELL% -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process -FilePath '%POWERSHELL%' -ArgumentList '%ELEVATED_ARGS%' -Verb RunAs" || (
    echo [ERROR] Falha ao enviar o pedido de elevacao. O usuario pode ter cancelado o UAC.
    pause
    exit /b 1
)

:: --- Completion