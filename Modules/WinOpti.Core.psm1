# \Modules\WinOpti.Core.psm1

function Write-WinOptiLog {
    [CmdletBinding()]
    param([string]$Message, [string]$Level = "INFO", [string]$LogFilePath)
    $colorMap = @{ "INFO"="White"; "WARN"="Yellow"; "ERROR"="Red"; "SUCCESS"="Green"; "DRYRUN"="Cyan" }
    $logColor = if ($colorMap.ContainsKey($Level)) { $colorMap[$Level] } else { "White" }
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $logColor
    try { Add-Content -Path $LogFilePath -Value $logEntry } catch { Write-Host "[$timestamp] [ERROR] Failed to write to log file '$LogFilePath'." -ForegroundColor Red }
}

function Get-WinOptiConfiguration {
    [CmdletBinding()]
    param([string]$ConfigPath)
    if (-not (Test-Path $ConfigPath)) { throw "Configuration file not found: $ConfigPath" }
    try {
        $configObject = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        # Iterates through all properties to expand any environment variables found
        foreach($prop in $configObject.psobject.properties) {
            if($prop.Value -is [string] -and $prop.Value.Contains('%')) { $prop.Value = [System.Environment]::ExpandEnvironmentVariables($prop.Value) }
        }
        # Specific handling for nested properties
        if ($configObject.PSObject.Properties.Name -contains 'directoriesToClean') { foreach ($dir in $configObject.directoriesToClean) { $dir.path = [System.Environment]::ExpandEnvironmentVariables($dir.path) } }
        if ($configObject.PSObject.Properties.Name -contains 'logFilesToClean') { foreach ($log in $configObject.logFilesToClean) { $log.path = [System.Environment]::ExpandEnvironmentVariables($log.path) } }
        if ($configObject.PSObject.Properties.Name -contains 'browsersToClean') { foreach ($browser in $configObject.browsersToClean) { $browser.basePath = [System.Environment]::ExpandEnvironmentVariables($browser.basePath) } }
        return $configObject
    } catch { throw "Failed to parse '$ConfigPath'. Ensure it is valid JSON. Error: $_" }
}

function Request-WinOptiConfirmation {
    [CmdletBinding()]
    param([string]$Message, [bool]$Unattended, [string]$LogFilePath)
    if ($Unattended) { Write-WinOptiLog -Level "WARN" -Message "Unattended: Confirmation '$Message' auto-accepted." -LogFilePath $LogFilePath; return $true }
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Confirm the action."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this action."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = $Host.UI.PromptForChoice("Confirmation", $Message, $options, 1)
    return $result -eq 0
}

Export-ModuleMember -Function *