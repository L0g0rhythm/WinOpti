@echo off
REM ==================== WINDOWS OPTIMIZER ====================
REM This script cleans temporary files, cache, and logs, optimizing the system.
REM Includes suggested improvements: function for directory removal, environment variables, basic error checking.
REM Make sure to run as administrator.

:: Get the current date and time to name the log file
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set "DATE=%%d-%%b-%%c"
for /f "tokens=1-2 delims=: " %%a in ("%time%") do set "TIME=%%a-%%b"
set "TIME=%TIME: =0%"  :: Replaces space with zero for consistent HH-MM format

:: Define the log file path (using Desktop for visibility, consider changing if preferred)
set "LOG_FILE=%USERPROFILE%\Desktop\windows_optimizer_log_%DATE%_%TIME%.txt"

:: --- Function Definitions ---

:AddLog
echo [%DATE% %TIME%] %~1 >> "%LOG_FILE%"
goto :eof

:RemoveDirectory
REM Safely removes a directory and its contents, logging the action.
if exist "%~1\" (
    echo Removing directory: %~1
    rd /s /q "%~1" >nul 2>&1
    if errorlevel 1 (
        call :AddLog "ERROR: Failed to remove directory: %~1"
    ) else (
        call :AddLog "Removed directory: %~1"
    )
) else (
    call :AddLog "INFO: Directory not found, skipping: %~1"
)
goto :eof

:: --- Main Script ---

:: Check if the script is being run as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrative privileges. Run as Administrator.
    pause
    exit /b 1
)

:: Initialize Log
echo. > "%LOG_FILE%" 2>nul
call :AddLog "System optimization started."

:: --- CLOSING UNNECESSARY PROCESSES ---
echo Closing unnecessary processes... (This may cause data loss in open applications!)
call :AddLog "Attempting to close unnecessary processes."

:: List of processes to be closed (Review this list carefully)
for %%P in (
    "ccleaner64.exe"
    "ccleaner.exe"
    "msedge.exe"
    "firefox.exe"
    "vivaldi.exe"
    "brave.exe"
    "chrome.exe"
    "Acrotray.exe"         :: Adobe Acrobat Update Service Helper
    "GoogleUpdate.exe"     :: Google Update
    "Skype.exe"
    "Spotify.exe"
    "Steam.exe"
    "Cortana.exe"          :: Consider if you use Cortana features
) do (
    tasklist /FI "IMAGENAME eq %%~P" 2>nul | find /I "%%~P" >nul
    if not errorlevel 1 (
        echo Closing %%~P...
        taskkill /F /IM "%%~P" >nul 2>&1
        if errorlevel 1 (
            call :AddLog "WARN: Failed to close process %%~P (may already be closing or access denied)."
        ) else (
            call :AddLog "Closed process: %%~P"
        )
    ) else (
        call :AddLog "INFO: Process %%~P not found running."
    )
)

:: --- REMOVING TEMPORARY FILES ---
echo Removing temporary files...
call :AddLog "Removing temporary files."
set "TEMP_USER=%LOCALAPPDATA%\Temp"
set "TEMP_WIN=%SystemRoot%\Temp"

REM Instead of deleting the root Temp folders, delete their CONTENTS. This is slightly safer.
echo Clearing User Temp: %TEMP_USER%
pushd "%TEMP_USER%" && (rd /s /q . 2>nul & popd) || call :AddLog "WARN: Could not access or clear %TEMP_USER%"
echo Clearing Windows Temp: %TEMP_WIN%
pushd "%TEMP_WIN%" && (rd /s /q . 2>nul & popd) || call :AddLog "WARN: Could not access or clear %TEMP_WIN%"
call :AddLog "Attempted clearing contents of temporary directories."

:: --- REMOVING UNNECESSARY LOGS ---
echo Removing unnecessary logs... (This might hinder future system diagnostics)
call :AddLog "Removing unnecessary logs."
for %%L in (
    "%SystemRoot%\Logs\CBS\*.log"
    "%SystemRoot%\Logs\MoSetup\*.log"
    "%SystemRoot%\Panther\*.log"      :: Setup/Upgrade logs
    "%SystemRoot%\inf\setupapi.*.log" :: Driver installation logs
    "%SystemRoot%\SoftwareDistribution\ReportingEvents.log"
    "%SystemRoot%\SoftwareDistribution\DataStore\Logs\edb*.log"
    REM Add other log patterns carefully
    REM "%SystemRoot%\Microsoft.NET\*.log" :: Be cautious, might be needed for .NET troubleshooting
) do (
    if exist "%%~L" (
        echo Deleting %%~L ...
        del /s /q /f "%%~L" >nul 2>&1
        if errorlevel 1 (
          call :AddLog "WARN: Failed to delete log(s): %%~L"
        ) else (
          call :AddLog "Deleted log(s): %%~L"
        )
    ) else (
         call :AddLog "INFO: Log pattern not found: %%~L"
    )
)

:: --- CLEARING BROWSER CACHE ---
echo Clearing browser cache...
call :AddLog "Clearing browser cache."

:: Microsoft Edge
set "EDGE_USER_DATA=%LOCALAPPDATA%\Microsoft\Edge\User Data"
if exist "%EDGE_USER_DATA%\" (
    call :RemoveDirectory "%EDGE_USER_DATA%\Default\Cache"
    call :RemoveDirectory "%EDGE_USER_DATA%\Default\Code Cache"
    call :RemoveDirectory "%EDGE_USER_DATA%\Default\GPUCache"
    call :RemoveDirectory "%EDGE_USER_DATA%\Default\Service Worker\CacheStorage"
    call :RemoveDirectory "%EDGE_USER_DATA%\Default\Service Worker\ScriptCache"
    call :AddLog "Cleared Edge cache folders."
) else ( call :AddLog "INFO: Edge User Data not found." )

:: Mozilla Firefox
REM NOTE: Firefox profiles can be complex. This targets default-release in LOCALAPPDATA. Might miss profiles in APPDATA or custom locations.
set "FIREFOX_PROFILES=%LOCALAPPDATA%\Mozilla\Firefox\Profiles"
if exist "%FIREFOX_PROFILES%\" (
    for /d %%D in ("%FIREFOX_PROFILES%\*.default*") do (
        call :RemoveDirectory "%%D\cache2"
        call :RemoveDirectory "%%D\OfflineCache"
        call :RemoveDirectory "%%D\startupCache"
        call :AddLog "Cleared cache for Firefox profile: %%~nxD"
    )
) else ( call :AddLog "INFO: Firefox profile folder (Local) not found." )
REM Consider checking %APPDATA%\Mozilla\Firefox\Profiles as well

:: Google Chrome
set "CHROME_USER_DATA=%LOCALAPPDATA%\Google\Chrome\User Data"
if exist "%CHROME_USER_DATA%\" (
    call :RemoveDirectory "%CHROME_USER_DATA%\Default\Cache"
    call :RemoveDirectory "%CHROME_USER_DATA%\Default\Code Cache"
    call :RemoveDirectory "%CHROME_USER_DATA%\Default\GPUCache"
    call :RemoveDirectory "%CHROME_USER_DATA%\Default\Service Worker\CacheStorage"
    call :RemoveDirectory "%CHROME_USER_DATA%\Default\Service Worker\ScriptCache"
    call :AddLog "Cleared Chrome cache folders."
) else ( call :AddLog "INFO: Chrome User Data not found." )

:: Opera (Assumes standard installation path)
set "OPERA_USER_DATA=%APPDATA%\Opera Software\Opera Stable"
if exist "%OPERA_USER_DATA%\" (
    call :RemoveDirectory "%OPERA_USER_DATA%\Cache"
    call :RemoveDirectory "%OPERA_USER_DATA%\Code Cache"
    call :RemoveDirectory "%OPERA_USER_DATA%\GPUCache"
    call :RemoveDirectory "%OPERA_USER_DATA%\Service Worker\CacheStorage"
    call :RemoveDirectory "%OPERA_USER_DATA%\Service Worker\ScriptCache"
    call :AddLog "Cleared Opera cache folders."
) else ( call :AddLog "INFO: Opera User Data not found." )

:: Brave
set "BRAVE_USER_DATA=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data"
if exist "%BRAVE_USER_DATA%\" (
    call :RemoveDirectory "%BRAVE_USER_DATA%\Default\Cache"
    call :RemoveDirectory "%BRAVE_USER_DATA%\Default\Code Cache"
    call :RemoveDirectory "%BRAVE_USER_DATA%\Default\GPUCache"
    call :RemoveDirectory "%BRAVE_USER_DATA%\Default\Service Worker\CacheStorage"
    call :RemoveDirectory "%BRAVE_USER_DATA%\Default\Service Worker\ScriptCache"
    call :AddLog "Cleared Brave cache folders."
) else ( call :AddLog "INFO: Brave User Data not found." )

:: Vivaldi
set "VIVALDI_USER_DATA=%LOCALAPPDATA%\Vivaldi\User Data"
if exist "%VIVALDI_USER_DATA%\" (
    call :RemoveDirectory "%VIVALDI_USER_DATA%\Default\Cache"
    call :RemoveDirectory "%VIVALDI_USER_DATA%\Default\Code Cache"
    call :RemoveDirectory "%VIVALDI_USER_DATA%\Default\GPUCache"
    call :RemoveDirectory "%VIVALDI_USER_DATA%\Default\Service Worker\CacheStorage"
    call :RemoveDirectory "%VIVALDI_USER_DATA%\Default\Service Worker\ScriptCache"
    call :AddLog "Cleared Vivaldi cache folders."
) else ( call :AddLog "INFO: Vivaldi User Data not found." )


:: --- Finalization ---
echo.
echo Optimization attempt completed! Check log file for details:
echo "%LOG_FILE%"
call :AddLog "Optimization finished."
echo.
pause
exit /b 0
