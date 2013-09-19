:: This file was called by ..\batch-shell.bat, to get the configuration environment variables, including:
::   BATCH_SHELL_LOG_DIR : the folder to contain scheduled batch file's runtime log
::   BATCH_SHELL_LOG_DATE: the date postfix of log file
::   BATCH_SHELL_LOG_TIME: the time(without date part) postfix of log file

:: NOTE: The environment variables in this file should be overridden by %USERPROFILE%\@batch-shell-config.bat

@IF [] equ [%BATCH_SHELL_LOG_DIR%] set BATCH_SHELL_LOG_DIR=%~dp0%..\.logs
:: depends on the OS version, DATE and TIME variable should be different, please make sure it's currect!
@set BATCH_SHELL_LOG_DATE=%date:~0,4%-%date:~5,2%-%date:~8,2%
@set BATCH_SHELL_LOG_TIME=%time:~0,2%-%time:~3,2%-%time:~6,5%
:: replace the heading BLANK
@set BATCH_SHELL_LOG_DATE=%BATCH_SHELL_LOG_DATE: =%
@set BATCH_SHELL_LOG_TIME=%BATCH_SHELL_LOG_TIME: =%
