:: FIXME: IN some case(deploy svn on Apache), following command MUST redirect to log file, else this hook should be inactive
mkdir "%1\logs-pre-commit"
CScript //Nologo "%1/hooks/pre-commit.js" %1 %2 > "%1\logs-pre-commit\%2.log"
EXIT %ERRORLEVEL%