@echo off
REM ==================== WINDOWS OPTIMIZER ====================
REM This script cleans temporary files, cache, and logs, optimizing the system.
REM Make sure to run as administrator.

:: Get the current date and time to name the log file
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do set DATE=%%d-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ("%time%") do set TIME=%%a-%%b
set "TIME=%TIME: =0%"  :: Replaces space with zero to ensure hour and minute are always two digits

:: Define the log file path with date and time
set "LOG_FILE=%USERPROFILE%\Desktop\windows_optimizer_log_%DATE%_%TIME%.txt"

:: Function to add entries to the log
:AddLog
echo %1 >> "%LOG_FILE%"
goto :eof

:: Check if the script is being run as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrative privileges. Run as Administrator.
    pause
    exit /b
)

:: Add log for start
call :AddLog "System optimization started at %date% %time%."

:: --------- CLOSING UNNECESSARY PROCESSES ---------
echo Closing unnecessary processes...
call :AddLog "Closing unnecessary processes."

:: List of processes to be closed
for %%P in (
    "ccleaner64.exe" 
    "ccleaner.exe" 
    "msedge.exe" 
    "firefox.exe" 
    "vivaldi.exe" 
    "brave.exe" 
    "chrome.exe"
    "Acrotray.exe"           :: Adobe Acrobat Update Service
    "GoogleUpdate.exe"        :: Google Update
    "Skype.exe"               :: Skype
    "Spotify.exe"             :: Spotify
    "Steam.exe"               :: Steam
    "Cortana.exe"             :: Cortana
) do (
    tasklist | find /i "%%P" >nul && (
        taskkill /F /IM %%P 2>nul
        call :AddLog "Process %%P closed."
    )
)

:: --------- REMOVING TEMPORARY FILES ---------
set "TEMP_USER=%USERPROFILE%\AppData\Local\Temp"
set "TEMP_WIN=C:\Windows\Temp"
call :RemoveDirectory "%TEMP_USER%"
call :RemoveDirectory "%TEMP_WIN%"
call :AddLog "Temporary files removed."

:: --------- REMOVING UNNECESSARY LOGS ---------
echo Removing unnecessary logs...
call :AddLog "Removing unnecessary logs."
for %%L in (
    "C:\Windows\Logs\CBS\*.log"
    "C:\Windows\Logs\MoSetup\*.log"
    "C:\Windows\Panther\*.log"
    "C:\Windows\inf\*.log"
    "C:\Windows\logs\*.log"
    "C:\Windows\SoftwareDistribution\*.log"
    "C:\Windows\Microsoft.NET\*.log"
) do (
    if exist %%L (
        del /s /q %%L 2>nul
        call :AddLog "Log %%L removed."
    )
)

:: --------- CLEARING BROWSER CACHE ---------
echo Clearing browser cache...
call :AddLog "Clearing browser cache."

:: Microsoft Edge
set "EDGE_USER=%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data"
if exist "%EDGE_USER%" (
    for %%D in ("Default\Cache" "Default\GPUCache" "Default\Service Worker") do (
        call :RemoveDirectory "%EDGE_USER%\%%D"
        call :AddLog "Cache %%D for Edge removed."
    )
)

:: Mozilla Firefox
set "FIREFOX_USER=%USERPROFILE%\AppData\Local\Mozilla\Firefox\Profiles"
for /d %%D in ("%FIREFOX_USER%\*.default-release") do (
    if exist "%%D\cache2" call :RemoveDirectory "%%D\cache2"
    call :AddLog "Cache for Firefox removed."
)

:: Google Chrome
set "CHROME_USER=%USERPROFILE%\AppData\Local\Google\Chrome\User Data"
if exist "%CHROME_USER%" (
    for %%D in ("Default\Cache" "Default\GPUCache" "Default\Service Worker") do (
        call :RemoveDirectory "%CHROME_USER%\%%D"
        call :AddLog "Cache %%D for Chrome removed."
    )
)

:: Opera
set "OPERA_USER=%USERPROFILE%\AppData\Roaming\Opera Software\Opera Stable"
if exist "%OPERA_USER%" (
    for %%D in ("Cache" "GPUCache" "Service Worker") do (
        call :RemoveDirectory "%OPERA_USER%\%%D"
        call :AddLog "Cache %%D for Opera removed."
    )
)

:: Brave
set "BRAVE_USER=%USERPROFILE%\AppData\Local\BraveSoftware\Brave-Browser\User Data"
if exist "%BRAVE_USER%" (
    for %%D in ("Default\Cache" "Default\GPUCache" "Default\Service Worker") do (
        call :RemoveDirectory "%BRAVE_USER%\%%D"
        call :AddLog "Cache %%D for Brave removed."
    )
)

:: Vivaldi
set "VIVALDI_USER=%USERPROFILE%\AppData\Local\Vivaldi\User Data"
if exist "%VIVALDI_USER%" (
    for %%D in ("Default\Cache" "Default\GPUCache" "Default\Service Worker") do (
        call :RemoveDirectory "%VIVALDI_USER%\%%D"
        call :AddLog "Cache %%D for Vivaldi removed."
    )
)

:: Finalization
echo Optimization completed successfully!
call :AddLog "Optimization completed at %date% %time%."
pause
