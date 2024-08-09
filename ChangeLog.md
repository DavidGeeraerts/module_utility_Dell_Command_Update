# :notebook:  Change Log: module_utility_Dell_Command_Update

## Features Heading
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Fixed` for any bug fixes.
- `Removed` for now removed features.
- `Security` in case of vulnerabilities.
- `Deprecated` for soon-to-be removed features.

[//]: # (Copy paste pallette)
[//]: # (#### Added)
[//]: # (#### Changed)
[//]: # (#### Fixed)
[//]: # (#### Removed)
[//]: # (#### Security)
[//]: # (#### Deprecated)


---

###  Version 1.9.0
#### Changed
- lastest package 5.4.0
- last known URI string
- Ordered local below everything else
- names for some variable files

#### Added
- WINGET installation attempt for DCU
- Comments

#### Fixed
- Parsing to get package latest version and URI

---

###  Version 1.8.0

#### Changed
- lastest package 5.2.0
- last known URI string


###  Version 1.7.1
#### Fixed
- parsing package URI string

#### Changed
- lastest package
- last known URI string


###  Version 1.7.0
#### Changed
- Support x32 or x64
- Latest package

###  Version 1.6.3
#### Fixed
- checking if x32 or x64 is installed

###  Version 1.6.2
#### Fixed
- Downloading DCU package with WGET requires using 'user-agent' 


###  Version 1.6.1
#### Changed
- Dell latest package URI


###  Version 1.6.0
#### Added
- WGET --no-check-certificate

#### Changed
- Default URI package
- Default DCU package

#### Fixed
- parsing Dell webpages to get URI and latest package


###  Version 1.5.0
#### Added
- Automatic parsing (regexp) of webpage to find website for latest package
- Automatic parsing (regexp) of latest package website to get package URI


###  Version 1.4.2

#### Changed
- Latest package

#### Fixed
- Parsing html page for latest package


###  Version 1.4.1 :new:

#### Added
- build variable
- Log info output
- remove existing DCU logs before running DCU


###  Version 1.4.0

#### Added
- Check if local repo is empty go fetch from website



###  Version 1.3.0

#### Added
- ChangeLog

#### Changed
- wget DCU subroutine
- Log_Shipping_Location to Log_Shipping

#### Removed
- Poweshell check



#### Version 1.1.0

- Improved logging
- Added cleanup
- Fixed winget


#### Version 1.0.0

- First release