function Start-ProcessTermination {
    param($Config, $DryRun, $Unattended, $LogFilePath)
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "--- Starting Process Termination ---"
    if (-not (Request-WinOptiConfirmation -Message "Terminate processes from config.json?" -Unattended $Unattended -LogFilePath $LogFilePath)) {
        Write-WinOptiLog -Level "WARN" -Message "User skipped process termination." -LogFilePath $LogFilePath
        return
    }
    foreach ($pName in $Config.processesToTerminate) {
        try {
            $p = Get-Process -Name $pName -ErrorAction SilentlyContinue
            if ($p) {
                if ($DryRun) {
                    Write-WinOptiLog -Level "DRYRUN" -Message "Would terminate '$pName'." -LogFilePath $LogFilePath
                } else {
                    Stop-Process -InputObject $p -Force
                    Write-WinOptiLog -Level "SUCCESS" -Message "'$pName' terminated." -LogFilePath $LogFilePath
                }
            } else {
                Write-WinOptiLog -Message "Process '$pName' is not running." -LogFilePath $LogFilePath
            }
        } catch {
            Write-WinOptiLog -Level "ERROR" -Message "Failed to terminate '$pName'. Error: $_" -LogFilePath $LogFilePath
        }
    }
}
Export-ModuleMember -Function *