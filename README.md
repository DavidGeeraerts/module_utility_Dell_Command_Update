# module_utility_Dell_Command_Updater

Wrapper module for [Dell Command Update](https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update).

## :ferris_wheel: Features

- Intelligent wrapper for installing and running Dell Command Update
- Program will install Dell Command Update if not present.
- Checks local network file share repository for package.
- If fetching from Dell website, parses for the latest version.
- Checks if system is Dell
- Uses `Wget` to download package.
- Installs `Chocolatey` package manager if `Wget` not installed.
- Uses `Winget` if `Chocolatey` isn't available
- Checks if running with administrative privilege
- Local log
- Log shipping to log server

## Usage

The wrapper is meant to facilitate large scale deployment and management.
Though the program can be run manually on individual machines, it's standard practice to:

- Add modules to a playbook
- Use a deployment tool such as [PsExec/PsExec64](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec) for large scale deployment and management. 

## :wrench: Configuration

- :gift: Change `$DCU_PACKAGE` to latest package 
- If there's a local software repository, configure: `$LOCAL_REPO` e.g. `SET $LOCAL_REPO=\\Server\Share`
- :satellite: If there's a log server on the network, configure: `$LOG_SHIPPING` e.g. `SET "$LOG_SHIPPING=\\Server\Share"`


::	:new: **Latest URI**

`SET "$DCU_PACKAGE=Dell-Command-Update-Windows-Universal-Application_PWD0M_WIN_4.4.0_A00.EXE"`

:link: `SET "$URI_PACKAGE=https://dl.dell.com/FOLDER07870027M/1/%$DCU_PACKAGE%"`

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

`SET "$LOG_SHIPPING="`


### :calendar: ToDo

- ChangeLog
- Provide configuration for scheduled task

### :notebook: 
[Change Log](./ChangeLog.md)

