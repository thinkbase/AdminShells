TaskScheduler
==========
The batch file for Windows Task Scheduler Service.

Usage
==========
## Command syntax
    batch-shell.bat [/daily] <command line>

## Configuration
### etc\config.bat
  The default configuration batch file.
### %USERPROFILE%\@batch-shell-config.bat
  The user configuration, to override the defaule configuration.

Example
==========
    batch-shell.bat "C:\Program Files\Java\jre6\bin\java" -version
    batch-shell.bat /daily "C:\Program Files\Java\jre6\bin\java" -version