:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Dell Command Update
::	https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::

:::: Initialize the console :::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
SETLOCAL Enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $SCRIPT_NAME=module_utility_Dell_Command_Update
SET $SCRIPT_VERSION=1.10.0
SET $SCRIPT_BUILD=20250618 0745
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=100
mode con:lines=44
Prompt DCU$G
color 03
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::###########################################################################::
:: Declare Global variables
::###########################################################################::

::	Last known package URI
:: Acts as a cache for the package URI to speed up the process
SET $DCU_PACKAGE=Dell-Command-Update-Windows-Universal-Application_P4DJW_WIN64_5.5.0_A00.EXE
:: [LAN] Local Repository
::	\\Server\Share
SET $LOCAL_REPO=\\SC-Tellus\Software\Dell\Dell_Command_Update
:: Log settings
::	Advise local storage for logging.
::	Log Directory
SET "$LOG_D=%Public%\Logs\%$SCRIPT_NAME%"
::	default log file name.
SET "$LOG_FILE=%COMPUTERNAME%_%$SCRIPT_NAME%.log"
:: Log Shipping
::	Advise network file share location
SET "$LOG_SHIPPING=\\SC-Tellus\Logs\Dell"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::


:: cleanup cache folder, and packages?
::  0 = OFF (NO)
::  1 = ON (YES)
SET $CLEANUP=0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: ##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SLT
	::	Start Lapse Time
	::	will be used to calculate how long the script runs for
	SET $START_TIME=%Time%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Banner
:: CONSOLE OUTPUT WHEN RUNNING Manually
	ECHO  ****************************************************************
	ECHO. 
	ECHO      %$SCRIPT_NAME% %$SCRIPT_VERSION%
	ECHO.
	echo 		%DATE% %TIME%
	echo.
	ECHO  ****************************************************************
	ECHO.
	ECHO Processing...
	echo.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check Log access
	IF NOT EXIST "%$LOG_D%" MD "%$LOG_D%" || SET $LOG_D=%PUBLIC%\Logs\%$SCRIPT_NAME%
	IF NOT EXIST "%$LOG_D%\cache" MD "%$LOG_D%\cache"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Powershell Check
	REM Assume powershell is available now with Windows 10(+)
	:: IF DEFINED PSModulePath (SET $PS_STATUS=1) ELSE (SET $PS_STATUS=0)

:fISO8601
	:: Function to ensure ISO 8601 Date format yyyy-mmm-dd
	:: Easiest way to get ISO date
::	IF %$PS_STATUS% EQU 0 GoTo skipPS
	@powershell Get-Date -format "yyyy-MM-dd" > "%$LOG_D%\cache\var_ISO8601_Date.txt"
	SET /P $ISO_DATE= < "%$LOG_D%\cache\var_ISO8601_Date.txt"
	IF NOT DEFINED $ISO_DATE SET $ISO_DATE=%DATE% 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:start
	ECHO %$ISO_DATE% %TIME% [INFO]	START... >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Script: %$SCRIPT_NAME% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Script Version: %$SCRIPT_VERSION% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Script Build: %$SCRIPT_BUILD% >> "%$LOG_D%\%$LOG_FILE%"	
	ECHO %$ISO_DATE% %TIME% [INFO]	Computer: %COMPUTERNAME% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	User: %USERNAME% >> "%$LOG_D%\%$LOG_FILE%"
	echo %$ISO_DATE% %TIME% [INFO]	Log Directory: %$LOG_D% >> "%$LOG_D%\%$LOG_FILE%"
	echo %$ISO_DATE% %TIME% [INFO]	Local repository: %$LOCAL_REPO% >> "%$LOG_D%\%$LOG_FILE%"
	echo %$ISO_DATE% %TIME% [INFO]	Log shipping: %$LOG_SHIPPING% >> "%$LOG_D%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Dell-Check
:: Manufacturer
	IF NOT EXIST "%$LOG_D%\cache\Systeminfo.txt" systeminfo > "%$LOG_D%\cache\SystemInfo.txt"
	FOR /F "tokens=2 delims=:" %%P IN ('FIND /I "System Manufacturer:" "%$LOG_D%\cache\SystemInfo.txt"') DO ECHO %%P > "%$LOG_D%\cache\var_systeminfo_SystemManufacturer.txt"
	SET /P $MANUFACTURER= < "%$LOG_D%\cache\var_systeminfo_SystemManufacturer.txt"
	for /f "tokens=* delims= " %%P IN ("%$MANUFACTURER%") DO SET $MANUFACTURER=%%P
	echo %$MANUFACTURER% | find /I "Dell" 2> nul
	SET $DELL_CHECK=%ERRORLEVEL%
	IF %$DELL_CHECK% EQU 0 GoTo skipDell-Check
	IF %$DELL_CHECK% NEQ 0 (
	@powershell Write-Host  "Program is only for Dell systems!" -ForegroundColor Red
	ECHO %$ISO_DATE% %TIME% [ERROR]	Not a Dell system! Aborting! >> "%$LOG_D%\%$LOG_FILE%"
	timeout 10
	GoTo Close
	)
:skipDell-Check
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check if running with Administrative Privilege
	openfiles.exe > "%$LOG_D%\cache\openfiles.txt" 2>nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% EQU 0 ECHO %$ISO_DATE% %TIME% [DEBUG]	Running with administrative privilege. >> "%$LOG_D%\%$LOG_FILE%"
	IF %$ADMIN_STATUS% NEQ 0 ECHO %$ISO_DATE% %TIME% [FATAL]	Not running with administrative privilege! >> "%$LOG_D%\%$LOG_FILE%"
	IF %$ADMIN_STATUS% NEQ 0 @powershell Write-Host  "FATAL ERROR! Not running with administrative privilege!" -ForegroundColor DarkRed
	IF %$ADMIN_STATUS% NEQ 0 timeout 30
	IF %$ADMIN_STATUS% NEQ 0 GoTo Close
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Check if Dell Command Update installed
	IF NOT EXIST "%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe" (SET $DELL_STATUS=0) ELSE (SET $DELL_STATUS=1)
	IF %$DELL_STATUS% EQU 0 GoTo DCU-Get
	GoTo DCU-Start

:DCU-Get
	REM Didn't seem to install correct version on x64
	REM If there's an existing version of DCU, WINGET doesn't seem to properly upgrade.
	@powershell Write-Host  "Dell Command Update not installed!" -ForegroundColor Yellow
	echo %$ISO_DATE% %TIME% [INFO]	Dell Command Update not installed! >> "%$LOG_D%\%$LOG_FILE%"
	timeout 2

:Local
	:: Network file share domain user check
	whoami /UPN 2> nul || GoTo skipLocal
	
	:: Check local repository if configured
	IF DEFINED $LOCAL_REPO (
		CD /D %PUBLIC%\Downloads
		IF EXIST %$LOCAL_REPO% dir /B /A:-D /O:-D "%$LOCAL_REPO%"> "%$LOG_D%\cache\local_DCU_package.txt"
		SET /P $DCU_PACKAGE= < "%$LOG_D%\cache\local_DCU_package.txt"
		@powershell Write-Host "Fetching from local repository..." -ForegroundColor White
		ROBOCOPY "%$LOCAL_REPO%" "%PUBLIC%\Downloads" %$DCU_PACKAGE% /R:1 /W:5
		IF NOT EXIST "%PUBLIC%\Downloads\%$DCU_PACKAGE%" GoTo skipLocal
		)
	GoTo DCU-install
:skipLocal

:remote
:: Remote Fetch
	IF NOT EXIST "%$LOG_D%\cache" MKDIR "%$LOG_D%\cache"
	CD /D "%$LOG_D%\cache"
:wget	
	REM requires WGET/WGET2 for processing
	SET $WGET_STATUS=0
	SET $WGET2_STATUS=0
	wget --version 1> nul 2> nul && SET $WGET_STATUS=1
	wget2 --version 1> nul 2> nul && SET $WGET2_STATUS=1
	:: Try to install wget or wget2
	IF %$WGET2_STATUS% EQU 0 winget install wget2 --accept-source-agreements
	wget2 --version 1> nul 2> nul || winget install wget --accept-source-agreements
	wget --version 1> nul 2> nul && SET $WGET_STATUS=1
	wget2 --version 1> nul 2> nul && SET $WGET2_STATUS=1
	If %$WGET_STATUS% EQU 1 GoTo DCU-Download
	If %$WGET2_STATUS% EQU 1 GoTo DCU-Download
:choco
REM When wget isn't installed try Chocolatey package manager
REM only wget is available with choco; no wget2
IF NOT DEFINED ChocolateyInstall GoTo skipChoco
choco upgrade wget /y
wget --version 1> nul 2> nul && SET $WGET_STATUS=1
:skipChoco
IF %$WGET_STATUS% EQU 1 GoTo DCU-Download

:err-wget
	@powershell Write-Host  "Dell Command Update not installed!" -ForegroundColor Red
	@powershell Write-Host  "WGET or WGET2 required for remote download" -ForegroundColor Red
	@powershell Write-Host  "Install Dell-Command-Update manually." -ForegroundColor Yellow
	timeout 10
	GoTo Close
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DCU-Download
REM Dell's webpage for downloading DCU is broken as of 2025-06-18
	CD /D "%$LOG_D%\cache"
	if exist dell-command-update.html del /F /Q dell-command-update.html
	REM DCU URI valid check: 2025-06-18
	wget --no-check-certificate "https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update.html" 
	for /f "tokens=6 delims=^< " %%P IN ('findstr /R /C:"DCU [0-9].[0-9] for" "%$LOG_D%\cache\dell-command-update.html"') DO ECHO %%P>> "%$LOG_D%\cache\DCU-Versions.txt"
	SET /P $DCU_LATEST= < "%$LOG_D%\cache\DCU-Versions.txt"
	echo %$ISO_DATE% %TIME% [DEBUG]	$DCU_LATEST: {%$DCU_LATEST%} >> "%$LOG_D%\%$LOG_FILE%"
	REM Already parsed
::	echo %$DCU_LATEST% | FINDSTR /R /C:"[0-9].[0-9].[0-9]" 2>nul || SET "$DCU_LATEST=%$DCU_LATEST%"
::	echo %$ISO_DATE% %TIME% [DEBUG]	$DCU_LATEST: {%$DCU_LATEST%} >> "%$LOG_D%\%$LOG_FILE%"
	
	:: Get DCU Latest Package Webpage
	:: Find strings, first one will be the latest
	:: URI search string seems to change
	if exist "%$LOG_D%\cache\DCU_Driver-URIs.txt" del /F /Q "%$LOG_D%\cache\DCU_Driver-URIs.txt"

	find /I "https://www.dell.com/support/home/en-us/drivers/DriversDetails?driverId=" "dell-command-update.html"> "%$LOG_D%\cache\DCU_Driver-URIs.txt"
	:: Sample String in DCU_Driver-URI.txt
	:: <li><a href="https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=9M35M" target="_blank">Dell Command | Update Windows Universal Application</a></li>
	:: Parse string to get just the URI, e.g. "https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=9M35M"
	for /f "tokens=3-4 delims== " %%P IN (%$LOG_D%\cache\DCU_Driver-URIs.txt) DO echo %%P=%%Q>> "%$LOG_D%\cache\DCU_Driver-URI.txt"
	:: first URI string is the latest DCU Universal package
	SET /P $DCU_Driver-URI= < "%$LOG_D%\cache\DCU_Driver-URI.txt"
	echo %$ISO_DATE% %TIME% [DEBUG]	$DCU_Driver-URI: {%$DCU_Driver-URI%} >> "%$LOG_D%\%$LOG_FILE%"	
::	Get DCU package URI, can't be hard coded
	if exist DCU_Webpage_Package_URI.html del /F /Q DCU_Webpage_Package.html
	wget --no-check-certificate %$DCU_Driver-URI% --output-document=DCU_Webpage_Package.html
	findstr /R /C:"DellDndDD.FileDetails = JSON.parse" "DCU_Webpage_Package.html" > DCU_Webpage_Package_URI.html
	REM	This will likely break at some point since tokens 8 is looking for "h", so any change in the working on the web page will break this. 
	for /f "tokens=8 delims=h" %%P IN (DCU_Webpage_Package_URI.html) DO echo h%%P> DCU_Webpage_Package_URI.txt"
	REM This should have extracted the URI starting with ttps:\\ which is why the "h" has to be added for https://
	REM More parsing of the string to get the exact URI
	REM Note the change of the file from html to txt.
	for /f "tokens=1 delims=^\" %%P IN (DCU_Webpage_Package_URI.txt) DO echo %%P> DCU_Webpage_Package_URI.txt
	
	REM No longer needed as current parsing created a clean URI
	REM Will include double quotes in string: "string"
	::	for /f "tokens=3 delims== " %%P IN (DCU_Webpage_Package_URI.txt) DO SET $DCU_PACKAGE_URI=%%P
	SET /P $DCU_PACKAGE_URI= < DCU_Webpage_Package_URI.txt
	echo %$ISO_DATE% %TIME% [DEBUG]	$DCU_PACKAGE_URI: {%$DCU_PACKAGE_URI%} >> "%$LOG_D%\%$LOG_FILE%"	
:: Get DCU latest Package	
	
	CD /D %PUBLIC%\Downloads
	:: Get 403 forbidden without User-Agent
	wget --no-check-certificate --user-agent=Mozilla "%$DCU_PACKAGE_URI%"
	echo %$ISO_DATE% %TIME% [INFO]	Dell Command Updated downloaded from Dell website. >> "%$LOG_D%\%$LOG_FILE%"
	for /f "tokens=5 delims=/" %%P IN (%$DCU_PACKAGE_URI%) DO SET $DCU_PACKAGE=%%P
	echo %$ISO_DATE% %TIME% [INFO]	Package: %$DCU_PACKAGE% >> "%$LOG_D%\%$LOG_FILE%"
:skip_DCU-Get		


:DCU-install
	IF NOT defined $DCU_PACKAGE GoTo skip-DCU-install
	CD /D %PUBLIC%\Downloads
	@powershell Write-Host "Installing Dell Command Update..." -ForegroundColor White
	IF EXIST "%$DCU_PACKAGE%" (%$DCU_PACKAGE% /s) ELSE (
	GoTo Close)
	echo %$ISO_DATE% %TIME% [INFO]	Installed: %$DCU_PACKAGE% >> "%$LOG_D%\%$LOG_FILE%"
:skip-DCU-install
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DCU-Start
	IF EXIST "%PROGRAMFILES%\Dell\CommandUpdate\dcu-cli.exe" cd /D "%PROGRAMFILES%\Dell\CommandUpdate"
	IF EXIST "%ProgramFiles(x86)%\Dell\CommandUpdate\dcu-cli.exe" cd /D "%ProgramFiles(x86)%\Dell\CommandUpdate"
	
:DCU-Version
	dcu-cli.exe /version > "%$LOG_D%\cache\DCU_Version.txt"
	FIND /I "application is designed to only operate on supported Dell systems" "%$LOG_D%\cache\DCU_Version.txt" 1> nul 2> nul && (
	@powershell Write-Host "This application is designed to only operate on supported Dell systems." -ForegroundColor Red
	echo %$ISO_DATE% %TIME% [ERROR]	Not a Dell Computer. Aborting! >> "%$LOG_D%\%$LOG_FILE%"
	GoTo Close
	)
	dcu-cli.exe /version >> "%$LOG_D%\%$LOG_FILE%"
	dcu-cli.exe /version
	echo.

:DCU-Scan
	rem -outputlog= doesn't work with %$LOG_D%, using %TEMP%
	if exist "%temp%\DCU_SCAN.log" DEL /F /Q "%temp%\DCU_SCAN.log"
	dcu-cli.exe /scan -outputlog="%temp%\DCU_SCAN.log"
	echo.
	echo Scan completed.
	type "%temp%\DCU_SCAN.log" >> "%$LOG_D%\%$LOG_FILE%"
	find /I "Number of applicable" "%temp%\DCU_SCAN.log"> "%$LOG_D%\cache\DCU_Scan_Updates.txt"
	for /f "skip=2 tokens=5 delims=:" %%P IN (%$LOG_D%\cache\DCU_Scan_Updates.txt) DO ECHO %%P> "%$LOG_D%\cache\DCU_Updates.txt"
	:: remove space
	for /f "tokens=1 delims= " %%P IN (%$LOG_D%\cache\DCU_Updates.txt) DO ECHO %%P> "%$LOG_D%\cache\DCU_Updates.txt"
	SET /P $DCU_UPDATES= < "%$LOG_D%\cache\DCU_Updates.txt"
	echo %$ISO_DATE% %TIME% [DEBUG]	$DCU_UPDATES: {%$DCU_UPDATES%} >> "%$LOG_D%\%$LOG_FILE%"
	if not defined $DCU_UPDATES GoTo DCU-Update
	IF %$DCU_UPDATES% EQU 0 GoTo Close


:DCU-Update
	rem -outputlog= doesn't work with %$LOG_D%, using %TEMP%
	if exist "%TEMP%\DCU_UPDATE.log" DEL /F /Q "%TEMP%\DCU_UPDATE.log"
	dcu-cli.exe /applyupdates -reboot=enable -outputlog="%TEMP%\DCU_UPDATE.log"
	echo.
	type "%TEMP%\DCU_UPDATE.log" >> "%$LOG_D%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Close
	::	Close out log file
	:: Calculate the actual lapse time
	@PowerShell.exe -c "$span=([datetime]'%Time%' - [datetime]'%$START_TIME%'); '{0:00}:{1:00}:{2:00}' -f $span.Hours, $span.Minutes, $span.Seconds" > "%$LOG_D%\cache\Total_Lapsed_Time.txt"
	SET /P $TOTAL_TIME= < "%$LOG_D%\cache\Total_Lapsed_Time.txt"
	ECHO %$ISO_DATE% %TIME% [INFO]	Time Lapsed (hh:mm:ss): %$TOTAL_TIME% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	End. >> "%$LOG_D%\%$LOG_FILE%"
	ECHO. >> "%$LOG_D%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Ship-Log
	:: Process log shipping
	IF NOT DEFINED $LOG_SHIPPING GoTo skipSL
	whoami /UPN 2> nul 1> nul || GoTo skipSL
	IF NOT EXIST "%$LOG_SHIPPING%" MD "%$LOG_SHIPPING%" || GoTo skipSL
	ROBOCOPY "%$LOG_D%" "%$LOG_SHIPPING%" %$LOG_FILE% /R:2 /W:30 /NDL /NFL /NP /LOG+:"%$LOG_D%\%$SCRIPT_NAME%_%COMPUTERNAME%_Shipping.log"
	@powershell Write-Host  "Log shipped!" -ForegroundColor Cyan
:skipSL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Cleanup
	IF %$CLEANUP% EQU 0 GoTo skipCleanup
	IF EXIST %PUBLIC%\Downloads\%$DCU_PACKAGE% DEL /F /Q %PUBLIC%\Downloads\%$DCU_PACKAGE%
	IF EXIST "%$LOG_D%\cache" RD /S /Q "%$LOG_D%\cache"
:skipCleanup
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:End
	echo.
	@powershell Write-Host  "All Done!" -ForegroundColor Green
	TIMEOUT 15
	ENDLOCAL
	Exit /B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::






:: Old WINGET Code
REM maybe one day it will work
GoTo skipWINGET
REM WINGET doesn't work
:: WINGET DCU Install		
	REM Now trying WINGET first to install DCU
	winget search --id "Dell.CommandUpdate.Universal" --accept-source-agreements > "%$LOG_D%\cache\v_winget_DCU.txt"
	Winget install --id "Dell.CommandUpdate.Universal" --accept-source-agreements > "%$LOG_D%\cache\winget.log"
	IF EXIST "%ProgramFiles(x86)%\Dell\CommandUpdate" "%ProgramFiles(x86)%\Dell\CommandUpdate\dcu-cli.exe" /version 2> nul && GoTo DCU-Start
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM This next section is all about a fallback method if WINGET fails to install.
	
	:: WGET returns 9009 for all ERRORLEVELS ;-(
	IF EXIST "%ProgramFiles(x86)%\GnuWin32\bin" echo %PATH% | FIND /I "%ProgramFiles(x86)%\GnuWin32\bin" 1> nul 2> nul || set "PATH=%PATH%;%ProgramFiles(x86)%\GnuWin32\bin"
	wget --version 1> "%$LOG_D%\cache\wget_version.txt" 2> nul || @powershell Write-Host "Wget is required to retrieve Dell Command Update package. Wget installation using Chocolatey package manager..." -ForegroundColor Yellow
	IF NOT DEFINED ChocolateyInstall @powershell Write-Host "Installing Chocolatey package manager..." -ForegroundColor DarkYellow
	IF NOT DEFINED ChocolateyInstall @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" & (
		echo %$ISO_DATE% %TIME% [INFO]	Installed Chocolatey package manager!  >> "%$LOG_D%\%$LOG_FILE%"
		)
	ECHO %PATH% | FIND /I "chocolatey\bin" 1> nul 2> nul || IF EXIST "%ALLUSERSPROFILE%\chocolatey\bin" SET PATH="%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
	IF EXIST "%PROGRAMDATA%\chocolatey" CD /D "%PROGRAMDATA%\chocolatey"
	choco --version 2> nul 1> nul && wget --version 1> "%$LOG_D%\cache\wget_version.txt" 2> nul || (
	echo %$ISO_DATE% %TIME% [INFO]	Installing wget to download Dell Command Update... >> "%$LOG_D%\%$LOG_FILE%"
	choco upgrade wget /y
	)
	CD /D "%ProgramData%\chocolatey\bin"
	wget --version 1> "%$LOG_D%\cache\wget_version.txt" 2> nul && GoTo skipWINGET
	
:WINGET
	:: Use winget as a fallback if Chocolatey ins't available.
	winget -v 2> nul || GoTo skipWINGET
	REM First search will produce verbage about acceopt source agreements
	winget search "wget" --accept-source-agreements > "%$LOG_D%\cache\v_winget_wget.txt"
	find /I "wget" "%$LOG_D%\cache\v_winget_wget.txt" > "%$LOG_D%\cache\winget_wget.txt"
	for /f "skip=2 tokens=3 delims=: " %%P IN (%$LOG_D%\cache\winget_wget.txt) Do Echo %%P> "%$LOG_D%\cache\winget_wget_ID.txt"
	set /P $WINGET_WGET_ID= < "%$LOG_D%\cache\winget_wget_ID.txt"
	winget install "%$WINGET_WGET_ID%" --accept-source-agreements
	IF EXIST "%ProgramFiles(x86)%\GnuWin32\bin" set "PATH=%PATH%;%ProgramFiles(x86)%\GnuWin32\bin" 
	REM winget changes the color
	color 03
:skipWINGET