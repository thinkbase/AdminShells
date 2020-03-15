@SETLOCAL
@echo off

set _PWD=%~dp0%
set _PWD=%_PWD:~0,-1%

:: 进入 mysql 目录
pushd "%_PWD%\mysql-*"
set _MYSQL_BASE=%cd%
set _MYSQL=%_MYSQL_BASE%\bin\mysql.exe
if not exist "%_MYSQL%" (
    echo 目录 "%_MYSQL_BASE%" 不是有效的 MySQL Windows 程序目录, 请检查。
	echo （注意: 目录 "%_PWD%" 下只能存在一个符合 mysql-* 名称的目录）
	echo.
	pause
	exit -1
)

call %_MYSQL% --default-character-set=utf8 %*

ENDLOCAL
