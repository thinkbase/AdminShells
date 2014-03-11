:: Check http connection, and repair it if connection fail
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set PATH=%~dp0.\..\.bin\wget-1.11.4-1\bin;%PATH%

:: Optional arguments(ENV Variable) =========================================================================
:: The http url to check
IF NOT DEFINED HTTP_CHECK_URL (
    set HTTP_CHECK_URL=http://localhost
)
:: The timeout(in second) when connect
IF NOT DEFINED HTTP_CHECK_TIMEOUT (
    set HTTP_CHECK_TIMEOUT=3
)
:: The command to repair
IF NOT DEFINED HTTP_REPAIR_CMD (
    set HTTP_REPAIR_CMD=cmd /c echo Nothing to do^^^!
)

:: get the timestamp
call %~dp0..\.includes\timestamp.bat
echo **^> Begin check [!HTTP_CHECK_URL!] at %TIMESTAMP% ...
:: Do wget: -O- : Redirect output to console; -t 3: Retry 3 times; --timeout: specify timeout seconds
wget -O- !HTTP_CHECK_URL! -t 3 --timeout !HTTP_CHECK_TIMEOUT!
set _ERROR_=%ERRORLEVEL%
IF %_ERROR_% NEQ 0 (
    echo ^>^>^> HTTP Connection fail, ERRORLEVEL=%_ERROR_% !
    echo ^>^>^> Begin to call [!HTTP_REPAIR_CMD!]
    call !HTTP_REPAIR_CMD!
    exit /B -1
)
echo **^> Finish check [!HTTP_CHECK_URL!] at %TIMESTAMP% .

ENDLOCAL

exit /b 0
