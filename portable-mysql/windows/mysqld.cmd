@SETLOCAL
@echo off

set _PWD=%~dp0%
set _PWD=%_PWD:~0,-1%

:: 进入 mysql 目录
pushd "%_PWD%\mysql-*"
set _MYSQL_BASE=%cd%
set _MYSQLD=%_MYSQL_BASE%\bin\mysqld.exe
if not exist "%_MYSQLD%" (
    echo 目录 "%_MYSQL_BASE%" 不是有效的 MySQL Windows 程序解压目录, 请检查。
	echo （注意: 目录 "%_PWD%" 下只能存在一个符合 mysql-* 名称的目录）
	echo.
	pause
	exit -1
)
popd

echo ^>^>^> MySQL 程序目录: "%_MYSQL_BASE%" .

:: 判断 MySQL 版本(目前只支持 5.7 和 8.0)
set _VER_57=false
echo %_MYSQL_BASE%|find "mysql-5.7.">nul&&set _VER_57=true
set _VER_80=false
echo %_MYSQL_BASE%|find "mysql-8.0.">nul&&set _VER_80=true
if "%_VER_57%"=="true" (
	echo ^>^>^> MySQL 版本为 5.7
) else if "%_VER_80%"=="true" (
	echo ^>^>^> MySQL 版本为 8.0
) else (
    echo 目录 "%_MYSQL_BASE%" 不是 MySQL 5.7 或者 8.0 版本的解压目录, 请检查。
	echo （注意: 目录名与 MySQL 下载文件名一致, 例如 "mysql-5.7.29-win32" 或者 "mysql-8.0.19-winx64"）
	echo.
	pause
	exit -1
)

set _MYSQL_WORK=%_PWD%\data
set _MYSQL_DATA=%_MYSQL_WORK%\db
echo ^>^>^> MySQL 数据目录: "%_MYSQL_DATA%" .

:: MySQL 启动参数
set _COMMON_ARGS=--defaults-file="%_PWD%\my.ini" --basedir="%_MYSQL_BASE%" --datadir="%_MYSQL_DATA%"
if "%_VER_57%"=="true" (
    :: MySQL 8.0 不支持 --log_syslog 参数
	set _COMMON_ARGS=%_COMMON_ARGS% --log_syslog=0
)
set _INITI_ARGS=%_COMMON_ARGS% --log-error="%_MYSQL_WORK%\initialize.log" --initialize
set _START_ARGS=%_COMMON_ARGS% --log-error="%_MYSQL_WORK%\error.log" --console --skip-host-cache --skip-name-resolve 

:: 如果没有 data 目录, 创建并初始化数据
if not exist "%_MYSQL_DATA%" (
	echo ^>^>^> 初始化 MySQL 数据库, 数据目录为 "%_MYSQL_DATA%" ...
    mkdir "%_MYSQL_DATA%"
	call "%_MYSQLD%" %_INITI_ARGS%
	echo ^>^>^> 初始化 MySQL 数据库完成, 详情参见 "%_MYSQL_WORK%\initialize.log".
)

:: 启动并执行 boot sql
set _INIT_SQL=boot.sql
if "%_VER_57%"=="true" (
	set _INIT_SQL=boot.5.7.sql
) else if "%_VER_80%"=="true" (
	set _INIT_SQL=boot.8.0.sql
)
if exist "%_PWD%\%_INIT_SQL%" (
    echo ^>^>^> 启动 MySQL 并执行 "%_PWD%\%_INIT_SQL%" ...
	echo ========================================
	type "%_PWD%\%_INIT_SQL%"
	echo ========================================
	echo.
	call "%_MYSQLD%" %_START_ARGS% --init-file="%_PWD%\%_INIT_SQL%"
) else (
    :: 如果没有 boot sql, 简单执行启动
    echo ^>^>^> 启动 MySQL ...
	call "%_MYSQLD%" %_START_ARGS%
)

ENDLOCAL

pause