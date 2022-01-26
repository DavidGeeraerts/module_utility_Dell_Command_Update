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
::	Latest URI
::	https://dl.dell.com/FOLDER07870027M/1/Dell-Command-Update-Windows-Universal-Application_PWD0M_WIN_4.4.0_A00.EXE
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
SET $SCRIPT_VERSION=1.1.0
SET $SCRIPT_BUILD=20220126
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=100
mode con:lines=44
Prompt DCU$G
color 03
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::###########################################################################::
:: Declare Global variables
::###########################################################################::

::	Latest URI
SET "$DCU_PACKAGE=Dell-Command-Update-Windows-Universal-Application_PWD0M_WIN_4.4.0_A00.EXE"
SET "$URI_PACKAGE=https://dl.dell.com/FOLDER07870027M/1/%$DCU_PACKAGE%"

:: Local Network Repository
::	\\Server\Share
SET $LOCAL_REPO=

:: Log settings
::	Advise local storage for logging.
::	Log Directory
SET "$LOG_D=%Public%\Logs\%$SCRIPT_NAME%"
::	default log file name.
SET "$LOG_FILE=%COMPUTERNAME%_%$SCRIPT_NAME%.log"
:: Log Shipping
::	Advise network file share location
SET "$LOG_SHIPPING_LOCATION="
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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Check Log access
	IF NOT EXIST "%$LOG_D%" MD "%$LOG_D%" || SET $LOG_D=%PUBLIC%\Logs\%$SCRIPT_NAME%
	IF NOT EXIST "%$LOG_D%\cache" MD "%$LOG_D%\cache"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Powershell Check
	echo.
	IF DEFINED PSModulePath (SET $PS_STATUS=1) ELSE (SET $PS_STATUS=0)

:fISO8601
	:: Function to ensure ISO 8601 Date format yyyy-mmm-dd
	:: Easiest way to get ISO date
	IF %$PS_STATUS% EQU 0 GoTo skipPS
	@powershell Get-Date -format "yyyy-MM-dd" > "%$LOG_D%\cache\var_ISO8601_Date.txt"
	SET /P $ISO_DATE= < "%$LOG_D%\cache\var_ISO8601_Date.txt"
:skipPS

:: Fallback if PowerShell not available
:fmanualISO
	:: Manually create the ISO 8601 date format
	IF DEFINED $ISO_DATE GoTo skipfmiso
	FOR /F "tokens=2 delims=/ " %%T IN ("%DATE%") DO SET $ISO_MONTH=%%T
	FOR /F "tokens=3 delims=/ " %%T IN ("%DATE%") DO SET $ISO_DAY=%%T
	FOR /F "tokens=4 delims=/ " %%T IN ("%DATE%") DO SET $ISO_YEAR=%%T
	SET $ISO_DATE=%$ISO_YEAR%-%$ISO_MONTH%-%$ISO_DAY%
:skipfmiso
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:start
	ECHO %$ISO_DATE% %TIME% [INFO]	START... >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Script: %$SCRIPT_NAME% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Script Version: %$SCRIPT_VERSION% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	Computer: %COMPUTERNAME% >> "%$LOG_D%\%$LOG_FILE%"
	ECHO %$ISO_DATE% %TIME% [INFO]	User: %USERNAME% >> "%$LOG_D%\%$LOG_FILE%"
	echo %$ISO_DATE% %TIME% [INFO]	Log Directory: %$LOG_D% >> "%$LOG_D%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Dell-Check
	wmic computersystem GET Manufacturer /VALUE | FIND /I "Dell" 2> nul
	SET $DELL_STATUS=%ERRORLEVEL%
	IF %$DELL_STATUS% EQU 0 GoTo skipDell-Check
	@powershell Write-Host  "Program is only for Dell systems!" -ForegroundColor Red
	ECHO %$ISO_DATE% %TIME% [ERROR]	Not a Dell system! Aborting! >> "%$LOG_D%\%$LOG_FILE%"
	timeout 10
	GoTo Close
:skipDell-Check

:Computer
	wmic computersystem GET Model /VALUE | Find /I "Model=" > "%$LOG_D%\cache\Compuer_model.txt"
	SET /P $COMPUTER_MODEL= < "%$LOG_D%\cache\Compuer_model.txt"
	ECHO %$ISO_DATE% %TIME% [INFO]	Computer %$COMPUTER_MODEL% >> "%$LOG_D%\%$LOG_FILE%"


:: Check if running with Administrative Privilege
	openfiles.exe > "%$LOG_D%\cache\openfiles.txt" 2>nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% EQU 0 ECHO %$ISO_DATE% %TIME% [DEBUG]	Running with administrative privilege. >> "%$LOG_D%\%$LOG_FILE%"
	IF %$ADMIN_STATUS% NEQ 0 ECHO %$ISO_DATE% %TIME% [FATAL]	Not running with administrative privilege! >> "%$LOG_D%\%$LOG_FILE%"
	IF %$ADMIN_STATUS% NEQ 0 IF %$PS_STATUS% EQU 1 @powershell Write-Host  "FATAL ERROR! Not running with administrative privilege!" -ForegroundColor DarkRed
	IF %$ADMIN_STATUS% NEQ 0 timeout 30
	IF %$ADMIN_STATUS% NEQ 0 GoTo Close
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:check
	IF NOT EXIST "%PROGRAMFILES%\Dell\CommandUpdate\dcu-cli.exe" GoTo DCU-Get
	GoTo DCU-Start

:DCU-Get
	REM Didn't seem to install correct version on x64
	REM installed as legacy, but now seems to install correctly.
	@powershell Write-Host  "Dell Command Update not installed!" -ForegroundColor Yellow
	echo %$ISO_DATE% %TIME% [INFO]	Dell Command Update not installed! >> "%$LOG_D%\%$LOG_FILE%"
	timeout 5
	
	CD /D %PUBLIC%\Downloads
	IF EXIST "%$DCU_PACKAGE%" GoTo DCU-install

:Local
	whoami /UPN 2> nul || GoTo skipLocal
	:: Check local repository if configured
	IF DEFINED $LOCAL_REPO (
		IF EXIST %$LOCAL_REPO% dir /B /A:-D /O:-D "%$LOCAL_REPO%"> "%$LOG_D%\cache\local_DCU_package.txt"
		SET /P $DCU_PACKAGE= < "%$LOG_D%\cache\local_DCU_package.txt"
		@powershell Write-Host "Fetching from local repository..." -ForegroundColor White
		ROBOCOPY "%$LOCAL_REPO%" "%PUBLIC%\Downloads" %$DCU_PACKAGE% /R:1 /W:5
		)
	IF EXIST "%$DCU_PACKAGE%" GoTo DCU-install
:skipLocal
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
	
	CD /D %PUBLIC%\Downloads
	wget --version 1> nul 2> nul && (
		wget "%$URI_PACKAGE%"
		echo %$ISO_DATE% %TIME% [INFO]	Dell Command Updated downloaded from Dell website. >> "%$LOG_D%\%$LOG_FILE%"
		echo %$ISO_DATE% %TIME% [INFO]	Package: %$DCU_PACKAGE% >> "%$LOG_D%\%$LOG_FILE%"
		GoTo skip_DCU-Get
		)
	:: When wget isn't installed to get the latest DCU package
	@powershell Write-Host  "Dell Command Update not installed!" -ForegroundColor Red
	@powershell Write-Host  "Feature to install not available!" -ForegroundColor Red
	@powershell Write-Host  "Install Dell-Command-Update manually." -ForegroundColor Yellow
	timeout 10
	GoTo Close
:skip_DCU-Get		

:DCU-install
	CD /D %PUBLIC%\Downloads
	dir /b /A:-D | FIND /I "Dell-Command-Update" > "%$LOG_D%\cache\DCU_PACKAGE.txt"
	SET /P $DCU_PACKAGE= < "%$LOG_D%\cache\DCU_PACKAGE.txt"
	@powershell Write-Host "Installing Dell Command Update..." -ForegroundColor White
	IF EXIST "%$DCU_PACKAGE%" (%$DCU_PACKAGE% /s) ELSE (
	GoTo Close)
	echo %$ISO_DATE% %TIME% [INFO]	Installed: %$DCU_PACKAGE% >> "%$LOG_D%\%$LOG_FILE%"
:skip-DCU-install
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:DCU-Start
	cd /D "%PROGRAMFILES%\Dell\CommandUpdate"

:DCU-Version
	dcu-cli.exe /version > "%$LOG_D%\cache\DCU_Version.txt"
	FIND /I "application is designed to only operate on supported Dell systems" "%$LOG_D%\cache\DCU_Version.txt" 1> nul 2> nul && (
	@powershell Write-Host "This application is designed to only operate on supported Dell systems." -ForegroundColor Red
	echo %$ISO_DATE% %TIME% [ERROR]	Not a Dell Computer. Aborting! >> "%$LOG_D%\%$LOG_FILE%"
	GoTo Close
	)
	dcu-cli.exe /version >> "%$LOG_D%\%$LOG_FILE%"
	echo.

:DCU-Scan
	rem -outputlog= doesn't work with %$LOG_D%, using %TEMP%
	dcu-cli.exe /scan -outputlog="%temp%\DCU_SCAN.log"
	echo.
	echo Scan completed.
	type "%temp%\DCU_SCAN.log" >> "%$LOG_D%\%$LOG_FILE%"
	find /I "Number of applicable" "%temp%\DCU_SCAN.log"> "%$LOG_D%\cache\DCU_Scan_Updates.txt"
	
	for /f "skip=2 tokens=5 delims=:" %%P IN (%$LOG_D%\cache\DCU_Scan_Updates.txt) DO ECHO %%P> "%$LOG_D%\cache\DCU_Updates.txt"
	:: remove space
	for /f "tokens=1 delims= " %%P IN (%$LOG_D%\cache\DCU_Updates.txt) DO ECHO %%P> "%$LOG_D%\cache\DCU_Updates.txt"
	SET /P $DCU_UPDATES= < "%$LOG_D%\cache\DCU_Updates.txt"
	IF %$DCU_UPDATES% EQU 0 GoTo Close


:DCU-Update
	rem -outputlog= doesn't work with %$LOG_D%, using %TEMP%
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
	IF NOT DEFINED $LOG_SHIPPING_LOCATION GoTo skipSL
	whoami /UPN 2> nul 1> nul || GoTo skipSL
	IF NOT EXIST "%$LOG_SHIPPING_LOCATION%" MD "%$LOG_SHIPPING_LOCATION%" || GoTo skipSL
	ROBOCOPY "%$LOG_D%" "%$LOG_SHIPPING_LOCATION%" %$LOG_FILE% /R:2 /W:30 /NDL /NFL /NP /LOG+:"%$LOG_D%\%$SCRIPT_NAME%_%COMPUTERNAME%_Shipping.log"
	IF %$PS_STATUS% EQU 1 @powershell Write-Host  "Log shipped!" -ForegroundColor Cyan
:skipSL
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Cleanup
	IF %$CLEANUP% EQU 0 GoTo skipCleanup
	IF EXIST %PUBLIC%\Downloads\%$DCU_PACKAGE% DEL /F /Q %PUBLIC%\Downloads\%$DCU_PACKAGE%
	IF EXIST "%$LOG_D%\cache" RD /S /Q "%$LOG_D%\cache"
:skipCleanup


:End
	echo.
	@powershell Write-Host  "All Done!" -ForegroundColor Green
	TIMEOUT 15
	ENDLOCAL
	Exit /B
