:: Example for usage:
set PWD=%~dp0.

set BAK_SOURCE_DIR=%PWD%\..
set BAK_TARGET_DIR=%PWD%\tmp
set BAK_PREFIX=test
set BAK_WILDCARD=*run*
call %PWD%\..\backup-with-timestamp.cmd

pause