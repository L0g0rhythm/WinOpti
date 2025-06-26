# WinOpti.ps1 - The main orchestrator script.
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Unattended
)
$Host.UI.RawUI.WindowTitle = "WinOpti v7.0 (Final Review)"
Set-StrictMode -Version Latest

# This function encapsulates the sequence of all optimizations to keep the code DRY.
function Invoke-AllOptimizations {
    param($splatParams, $optiConfig, $diskCleanupConfig)
    
    Write-WinOptiLog -Message "Running all optimizations..." -LogFilePath $splatParams.LogFilePath
    Start-ProcessTermination -Config $optiConfig @splatParams
    Start-BasicFileCleanup -Config $optiConfig @splatParams
    Start-SystemDiskCleanup -Config $diskCleanupConfig @splatParams
}

try {
    # Centralized Module Importing
    $modulePathBase = Join-Path $PSScriptRoot "Modules"
    Import-Module (Join-Path $modulePathBase "WinOpti.Core.psm1") -Force
    Import-Module (Join-Path $modulePathBase "WinOpti.Process.psm1") -Force
    Import-Module (Join-Path $modulePathBase "WinOpti.FileCleanup.psm1") -Force
    Import-Module (Join-Path $modulePathBase "WinOpti.DiskCleanup.psm1") -Force

    # Load All Configurations
    $logConfig = Get-WinOptiConfiguration -ConfigPath (Join-Path $PSScriptRoot "Config\logging.config.json")
    $optiConfig = Get-WinOptiConfiguration -ConfigPath (Join-Path $PSScriptRoot "Config\config.json")
    $diskCleanupConfig = Get-WinOptiConfiguration -ConfigPath (Join-Path $PSScriptRoot "Config\diskcleanup.config.json")

    # Setup Logging
    $logDirectory = if ([string]::IsNullOrWhiteSpace($logConfig.logDirectory)) { Join-Path $PSScriptRoot "Logs" } else { $logConfig.logDirectory }
    if (-not (Test-Path -Path $logDirectory)) { New-Item -ItemType Directory -Path $logDirectory | Out-Null }
    $logFileName = "$($logConfig.logFileNamePrefix)$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
    $finalLogPath = Join-Path -Path $logDirectory -ChildPath $logFileName

    Write-WinOptiLog -LogFilePath $finalLogPath -Message "--- Script session started ---"
    
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "Administrator privileges required." }

    $splatParams = @{ DryRun = $DryRun; Unattended = $Unattended; LogFilePath = $finalLogPath }

    if ($Unattended) {
        Write-WinOptiLog -Level "WARN" -Message "UNATTENDED MODE: Running all optimizations." -LogFilePath $finalLogPath
        Invoke-AllOptimizations -splatParams $splatParams -optiConfig $optiConfig -diskCleanupConfig $diskCleanupConfig
        Write-WinOptiLog -Level "SUCCESS" -Message "All unattended tasks finished." -LogFilePath $finalLogPath
        Write-WinOptiLog -Message "Log file saved to: $finalLogPath" -LogFilePath $finalLogPath
        if (-not $env:CI) { Read-Host "Press Enter to exit" }
        exit
    }

    do {
        Clear-Host
        Write-WinOptiLog -Message "WinOpti v7.0 (Final Review)" -LogFilePath $finalLogPath
        if ($DryRun) { Write-WinOptiLog -Level "DRYRUN" -Message "DRY RUN MODE IS ACTIVE" -LogFilePath $finalLogPath }
        Write-Host "`n [1] Terminate Non-Essential Processes`n [2] Basic File Cleanup (Temp, Logs, Cache)`n [3] Advanced System Cleanup (Windows Update, Recycle Bin, etc.)`n`n [A] Run ALL Optimizations`n [Q] Quit`n`nLog: $finalLogPath"
        $choice = Read-Host "`nEnter your choice"

        switch ($choice) {
            "1" { Start-ProcessTermination -Config $optiConfig @splatParams }
            "2" { Start-BasicFileCleanup -Config $optiConfig @splatParams }
            "3" { Start-SystemDiskCleanup -Config $diskCleanupConfig @splatParams }
            "A" { Invoke-AllOptimizations -splatParams $splatParams -optiConfig $optiConfig -diskCleanupConfig $diskCleanupConfig }
            "q" { Write-WinOptiLog -Message "--- Script session finished ---" -LogFilePath $finalLogPath }
            default { Write-WinOptiLog -Level "WARN" -Message "Invalid option." -LogFilePath $finalLogPath }
        }
        if ($choice -ne 'q' -and $choice -ne '') { Write-WinOptiLog -Level "SUCCESS" -Message "Task finished. Press Enter to return." -LogFilePath $finalLogPath; Read-Host }
    } while ($choice -ne 'q')
}
catch {
    $errorMessage = "A critical error occurred: $_"
    Write-Host "[ERROR] $errorMessage" -ForegroundColor Red
    if ($finalLogPath) { Add-Content -Path $finalLogPath -Value "[ERROR] $errorMessage" }
    if (-not $env:CI) { Read-Host "Press Enter to exit" }
}