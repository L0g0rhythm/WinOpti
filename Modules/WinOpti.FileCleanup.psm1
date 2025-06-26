# \Modules\WinOpti.FileCleanup.psm1

function Start-BasicFileCleanup {
    param($Config, $DryRun, $Unattended, $LogFilePath)
    
    # Directory Cleanup
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "--- Starting Temp Directory Cleanup ---"
    foreach ($dir in $Config.directoriesToClean) {
        if (Test-Path $dir.path) {
            if (Request-WinOptiConfirmation -Message "Clean '$($dir.description)'?" -Unattended $Unattended -LogFilePath $LogFilePath) {
                try {
                    # Add -ErrorAction Stop to ensure the catch block is triggered on failure
                    $items = Get-ChildItem $dir.path -Recurse -Force -ErrorAction SilentlyContinue
                    if ($items) {
                        if ($DryRun) { Write-WinOptiLog -Level DRYRUN -Message "Would clean '$($dir.path)'." -LogFilePath $LogFilePath }
                        else { 
                            Remove-Item $items.FullName -Recurse -Force -ErrorAction Stop
                            Write-WinOptiLog -Level SUCCESS -Message "'$($dir.description)' cleaned." -LogFilePath $LogFilePath 
                        }
                    } else { Write-WinOptiLog -Message "Directory '$($dir.description)' is empty." -LogFilePath $LogFilePath }
                } catch { 
                    Write-WinOptiLog -Level "ERROR" -Message "Failed to clean '$($dir.description)'. Error: $_" -LogFilePath $LogFilePath 
                }
            } else { Write-WinOptiLog -Level WARN -Message "User skipped cleaning '$($dir.description)'." -LogFilePath $LogFilePath }
        } else { Write-WinOptiLog -Level WARN -Message "Path not found for '$($dir.description)'." -LogFilePath $LogFilePath }
    }

    # Log File Cleanup
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "--- Starting Log File Cleanup ---"
    foreach ($log in $Config.logFilesToClean) {
        if (Get-Item -Path $log.path -ErrorAction SilentlyContinue) {
            if (Request-WinOptiConfirmation -Message "Clean '$($log.description)'?" -Unattended $Unattended -LogFilePath $LogFilePath) {
                try {
                    if ($DryRun) { 
                        Write-WinOptiLog -Level DRYRUN -Message "Would clean '$($log.path)'." -LogFilePath $LogFilePath 
                    } else { 
                        # THIS IS THE CORRECTED LINE: Added -ErrorAction Stop
                        Remove-Item $log.path -Force -Recurse -ErrorAction Stop
                        Write-WinOptiLog -Level SUCCESS -Message "'$($log.description)' cleaned." -LogFilePath $LogFilePath 
                    }
                } catch { 
                    Write-WinOptiLog -Level "ERROR" -Message "Failed to clean '$($log.description)'. File may be in use. Error: $_" -LogFilePath $LogFilePath 
                }
            } else { Write-WinOptiLog -Level WARN -Message "User skipped cleaning '$($log.description)'." -LogFilePath $LogFilePath }
        }
    }

    # Browser Cache Cleanup
    Write-WinOptiLog -LogFilePath $LogFilePath -Message "--- Starting Browser Cache Cleanup ---"
    foreach ($browser in $Config.browsersToClean) {
        if (Test-Path $browser.basePath) {
            if (Request-WinOptiConfirmation -Message "Clean cache for $($browser.name)?" -Unattended $Unattended -LogFilePath $LogFilePath) {
                foreach ($cachePath in $browser.cachePaths) {
                    try {
                        $resolvedPath = Resolve-Path (Join-Path $browser.basePath $cachePath) -ErrorAction SilentlyContinue
                        if ($resolvedPath) {
                            if ($DryRun) { Write-WinOptiLog -Level DRYRUN -Message "Would clean cache '$resolvedPath'." -LogFilePath $LogFilePath }
                            else { 
                                # Add -ErrorAction Stop here as well for consistency
                                Remove-Item $resolvedPath -Recurse -Force -ErrorAction Stop
                                Write-WinOptiLog -Level SUCCESS -Message "Cache '$resolvedPath' removed." -LogFilePath $LogFilePath 
                            }
                        }
                    } catch { Write-WinOptiLog -Level ERROR -Message "Failed cleaning '$resolvedPath'. In use? Error: $_" -LogFilePath $LogFilePath }
                }
            } else { Write-WinOptiLog -Level WARN -Message "User skipped cache for $($browser.name)." -LogFilePath $LogFilePath }
        } else { Write-WinOptiLog -Level INFO -Message "$($browser.name) profile not found." -LogFilePath $LogFilePath }
    }
}
Export-ModuleMember -Function *