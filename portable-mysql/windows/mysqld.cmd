@SETLOCAL
@echo off

set _PWD=%~dp0%
set _PWD=%_PWD:~0,-1%

:: ���� mysql Ŀ¼
pushd "%_PWD%\mysql-*"
set _MYSQL_BASE=%cd%
set _MYSQLD=%_MYSQL_BASE%\bin\mysqld.exe
if not exist "%_MYSQLD%" (
    echo Ŀ¼ "%_MYSQL_BASE%" ������Ч�� MySQL Windows �����ѹĿ¼, ���顣
	echo ��ע��: Ŀ¼ "%_PWD%" ��ֻ�ܴ���һ������ mysql-* ���Ƶ�Ŀ¼��
	echo.
	pause
	exit -1
)
popd

echo ^>^>^> MySQL ����Ŀ¼: "%_MYSQL_BASE%" .

:: �ж� MySQL �汾(Ŀǰֻ֧�� 5.7 �� 8.0)
set _VER_57=false
echo %_MYSQL_BASE%|find "mysql-5.7.">nul&&set _VER_57=true
set _VER_80=false
echo %_MYSQL_BASE%|find "mysql-8.0.">nul&&set _VER_80=true
if "%_VER_57%"=="true" (
	echo ^>^>^> MySQL �汾Ϊ 5.7
) else if "%_VER_80%"=="true" (
	echo ^>^>^> MySQL �汾Ϊ 8.0
) else (
    echo Ŀ¼ "%_MYSQL_BASE%" ���� MySQL 5.7 ���� 8.0 �汾�Ľ�ѹĿ¼, ���顣
	echo ��ע��: Ŀ¼���� MySQL �����ļ���һ��, ���� "mysql-5.7.29-win32" ���� "mysql-8.0.19-winx64"��
	echo.
	pause
	exit -1
)

set _MYSQL_WORK=%_PWD%\data
set _MYSQL_DATA=%_MYSQL_WORK%\db
echo ^>^>^> MySQL ����Ŀ¼: "%_MYSQL_DATA%" .

:: MySQL ��������
set _COMMON_ARGS=--defaults-file="%_PWD%\my.ini" --basedir="%_MYSQL_BASE%" --datadir="%_MYSQL_DATA%"
if "%_VER_57%"=="true" (
    :: MySQL 8.0 ��֧�� --log_syslog ����
	set _COMMON_ARGS=%_COMMON_ARGS% --log_syslog=0
)
set _INITI_ARGS=%_COMMON_ARGS% --log-error="%_MYSQL_WORK%\initialize.log" --initialize
set _START_ARGS=%_COMMON_ARGS% --log-error="%_MYSQL_WORK%\error.log" --console --skip-host-cache --skip-name-resolve 

:: ���û�� data Ŀ¼, ��������ʼ������
if not exist "%_MYSQL_DATA%" (
	echo ^>^>^> ��ʼ�� MySQL ���ݿ�, ����Ŀ¼Ϊ "%_MYSQL_DATA%" ...
    mkdir "%_MYSQL_DATA%"
	call "%_MYSQLD%" %_INITI_ARGS%
	echo ^>^>^> ��ʼ�� MySQL ���ݿ����, ����μ� "%_MYSQL_WORK%\initialize.log".
)

:: ������ִ�� boot sql
set _INIT_SQL=boot.sql
if "%_VER_57%"=="true" (
	set _INIT_SQL=boot.5.7.sql
) else if "%_VER_80%"=="true" (
	set _INIT_SQL=boot.8.0.sql
)
if exist "%_PWD%\%_INIT_SQL%" (
    echo ^>^>^> ���� MySQL ��ִ�� "%_PWD%\%_INIT_SQL%" ...
	echo ========================================
	type "%_PWD%\%_INIT_SQL%"
	echo ========================================
	echo.
	call "%_MYSQLD%" %_START_ARGS% --init-file="%_PWD%\%_INIT_SQL%"
) else (
    :: ���û�� boot sql, ��ִ������
    echo ^>^>^> ���� MySQL ...
	call "%_MYSQLD%" %_START_ARGS%
)

ENDLOCAL

pause