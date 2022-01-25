# module_utility_Dell_Command_Updater

Wrapper module for [Dell Command Update](https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update).

## Features

- Program will install Dell Command Update if not present.
- Checks if system is Dell
- Checks local network file share repository for package.
- Uses 'Wget' to download package.
- Installs 'Chocolatey' package manager if 'Wget' not installed.
- Checks if running with administrative privilege
- Local log
- Log shipping to log server


## Configuration

::	**Latest URI**
`SET "$DCU_PACKAGE=Dell-Command-Update-Windows-Universal-Application_PWD0M_WIN_4.4.0_A00.EXE"`
`SET "$URI_PACKAGE=https://dl.dell.com/FOLDER07870027M/1/%$DCU_PACKAGE%"`

:: **Local Network Repository**
::	\\\Server\Share
`SET $LOCAL_REPO=`

:: **Log settings**
::	Advise local storage for logging.
::	Log Directory
`SET "$LOG_D=%Public%\Logs\%$SCRIPT_NAME%"`
::	default log file name.
`SET "$LOG_FILE=%COMPUTERNAME%_%$SCRIPT_NAME%.log"`

:: **Log Shipping**
::	Advise network file share location
::	\\\Server\Share
`SET "$LOG_SHIPPING_LOCATION="`


### ToDo

- Provide configuration for scheduled task