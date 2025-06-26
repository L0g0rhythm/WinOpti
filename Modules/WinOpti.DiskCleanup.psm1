# Module for automating the Windows Disk Cleanup utility (cleanmgr.exe).
function Start-SystemDiskCleanup {
    param($Config, $DryRun, $Unattended, $LogFilePath)
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "--- Starting Advanced System Disk Cleanup ---"
    if (-not (Request-WinOptiConfirmation -Message "Run advanced Disk Cleanup (cleanmgr.exe)?" -Unattended $Unattended -LogFilePath $LogFilePath)) {
        Write-WinOptiLog -Level "WARN" -Message "User skipped advanced disk cleanup." -LogFilePath $LogFilePath
        return
    }

    $handlers = $Config.diskCleanupHandlers
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $sagesetId = "1337"
    
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "Configuring Disk Cleanup handlers..."
    foreach ($h in $handlers) {
        $hPath = Join-Path $regPath $h
        if (Test-Path $hPath) {
            try {
                if ($DryRun) {
                    Write-WinOptiLog -Level "DRYRUN" -Message "Would enable handler '$h' for cleanup." -LogFilePath $LogFilePath
                } else {
                    Set-ItemProperty -Path $hPath -Name "StateFlags" -Value "2" -Type DWord -Force
                    Write-WinOptiLog -Level "INFO" -Message "Handler '$h' enabled." -LogFilePath $LogFilePath
                }
            } catch {
                Write-WinOptiLog -Level "ERROR" -Message "Failed to set registry for handler '$h'. Error: $_" -LogFilePath $LogFilePath
            }
        } else {
            Write-WinOptiLog -Level "WARN" -Message "Handler '$h' not found in registry." -LogFilePath $LogFilePath
        }
    }

    Write-WinOptiLog -LogFilePath $LogFilePath -Message "Executing cleanmgr.exe silently. This may take a long time."
    try {
        if ($DryRun) {
            Write-WinOptiLog -Level "DRYRUN" -Message "Would execute 'cleanmgr.exe /sagerun:$sagesetId'." -LogFilePath $LogFilePath
        } else {
            $p = Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:$sagesetId" -Wait -PassThru
            if ($p.ExitCode -eq 0) {
                Write-WinOptiLog -Level "SUCCESS" -Message "Advanced Disk Cleanup completed." -LogFilePath $LogFilePath
            } else {
                Write-WinOptiLog -Level "ERROR" -Message "cleanmgr.exe exited with code: $($p.ExitCode)." -LogFilePath $LogFilePath
            }
        }
    }
    finally {
        # This block ALWAYS runs to ensure the registry is cleaned up, unless in DryRun mode.
        if (-not $DryRun) {
            Write-WinOptiLog -LogFilePath $LogFilePath -Message "Reverting registry StateFlags to default..."
            foreach ($h in $handlers) {
                $hPath = Join-Path $regPath $h
                if (Test-Path $hPath) {
                    try {
                        Set-ItemProperty -Path $hPath -Name "StateFlags" -Value "0" -Type DWord -Force
                    } catch {
                        # We log a warning here as failure to revert is not critical to the script's success.
                        Write-WinOptiLog -Level "WARN" -Message "Could not revert StateFlags for handler '$h'." -LogFilePath $LogFilePath
                    }
                }
            }
            Write-WinOptiLog -LogFilePath $LogFilePath -Message "Registry state reverted."
        }
    }
}
Export-ModuleMember -Function *