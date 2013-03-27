:: Backup(compress with 7-zip format) all sub-directories in a directory, with timestamp as the 7-zip file name's postfix
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set PATH=%PATH%;%~dp0.\runtime

:: Reqiured arguments(ENV Variable) ===================================================================
call %~dp0..\.includes\checkenv.bat BAK_SOURCE_DIR "Please indicate the directory which sub-directories should be backup"
IF %CHECKENV_ERRCODE%==-1 exit /b 1
call %~dp0..\.includes\checkenv.bat BAK_TARGET_DIR "Please specify the directory to save the backup files"
IF %CHECKENV_ERRCODE%==-1 exit /b 2

:: Optional arguments(ENV Variable) =========================================================================
:: The backup file name - <%BAK_PREFIX%>.<sub-directory>.<timestamp>.7z
IF NOT DEFINED BAK_PREFIX (
    set BAK_PREFIX=backup-with-timestamp
)
:: The wildcard to filter the sub-directories
IF NOT DEFINED BAK_WILDCARD (
    set BAK_WILDCARD=*
)

:: get the timestamp
call %~dp0..\.includes\timestamp.bat
echo Begin backup at %TIMESTAMP% ...

:: Backup sub-directories(NOTE: we only backup the sub-directory, files should be skiped)
pushd %BAK_SOURCE_DIR%
for  /d  %%i  in (%BAK_WILDCARD%)  do (
    set _DIR=%%i
    set _7Z=%BAK_TARGET_DIR%\%BAK_PREFIX%.%%i.%TIMESTAMP%.7z
    echo.
    echo * Begin backup ========================================================================
    echo Backup directory "!_DIR!" into 7-zip compress file "!_7Z!" ...
    call 7z.exe a "!_7Z!" "!_DIR!"
    call 7z.exe t "!_7Z!"
)
popd

ENDLOCAL

exit /b 0
:: Example for usage:
set BAK_SOURCE_DIR=E:\Workspace\ffmpeg
set BAK_TARGET_DIR=E:\usr\local
set BAK_PREFIX=demo
set BAK_WILDCARD=*e*
backup-with-timestamp.cmd