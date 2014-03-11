:: Call other program(always batch file) and log stdout/stderr into log file
:: Syntax: batch-shell.bat [/daily] <command line>
::   /daily - use one log file per day(default is one file every time running the command line)


@SETLOCAL
@echo off

set _PWD=%~dp0%
set _PWD=%_PWD:~0,-1%

set TIME_STAMP=%date% %time%

:: Call configuration
call %_PWD%\etc\config.bat
if exist "%USERPROFILE%\@batch-shell-config.bat" (
    call "%USERPROFILE%\@batch-shell-config.bat"
)
echo BATCH_SHELL_LOG_DIR=[%BATCH_SHELL_LOG_DIR%], BATCH_SHELL_LOG_DATE=[%BATCH_SHELL_LOG_DATE%], BATCH_SHELL_LOG_TIME=[%BATCH_SHELL_LOG_TIME%]
IF [] equ [%BATCH_SHELL_LOG_DATE%] (
     echo Environment variable BATCH_SHELL_LOG_DATE not found, maybe %USERPROFILE%\@batch-shell-config.bat error
     exit /b -1
)
IF [] equ [%BATCH_SHELL_LOG_TIME%] (
     echo Environment variable BATCH_SHELL_LOG_TIME not found, maybe %USERPROFILE%\@batch-shell-config.bat error
     exit /b -1
)

set CMD_LINE=%*
set PROG_NAME=%1
set CUR_DATE=%BATCH_SHELL_LOG_DATE%.%BATCH_SHELL_LOG_TIME%
if [%1]==[/daily] (
    set CUR_DATE=%BATCH_SHELL_LOG_DATE%

    :: trim "/daily "
    set CMD_LINE=%CMD_LINE:~7%
    set PROG_NAME=%2
)
:: Syntax validation
IF [] equ [%PROG_NAME%] (
     echo Can't find PROG_NAME^(program to run^), maybe command syntax error.
     exit /b -1
)

:: CMD_LINE may contain driver letter and directory
set PROG_NAME=%PROG_NAME::=__%
set PROG_NAME=%PROG_NAME:\=_%
:: remove double quotes, such as "C:\Program Files\Java\jre6\bin\java"
set PROG_NAME=%PROG_NAME:"=%

mkdir "%BATCH_SHELL_LOG_DIR%"

set LOG_FILE=%BATCH_SHELL_LOG_DIR%\%PROG_NAME%.%CUR_DATE%.log

echo Run [%*] at %TIME_STAMP% , with log file %LOG_FILE% ...

echo. >> "%LOG_FILE%"
echo ******************************************************************************** >> "%LOG_FILE%"
echo *                                                                              * >> "%LOG_FILE%"
echo *  Begin to run [%CMD_LINE%] ...        >> "%LOG_FILE%"
echo *   - User    : %USERNAME%     >> "%LOG_FILE%"
echo *   - Time    : %TIME_STAMP%   >> "%LOG_FILE%"
echo *   - Log file: %LOG_FILE%     >> "%LOG_FILE%"
echo *                                                                              * >> "%LOG_FILE%"
echo ******************************************************************************** >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

call %CMD_LINE% >> "%LOG_FILE%" 2>&1

echo. >> "%LOG_FILE%"
echo ******************************************************************************** >> "%LOG_FILE%"
echo *                                                                              * >> "%LOG_FILE%"
echo *  Run [%CMD_LINE%] completed, %date% %time% . >> "%LOG_FILE%"
echo *                                                                              * >> "%LOG_FILE%"
echo ******************************************************************************** >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
echo . >> "%LOG_FILE%"

@ENDLOCAL