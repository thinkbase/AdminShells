:: Run wmic command and convert output from unicode to ascii

@echo off
SETLOCAL

call %~dp0..\.includes\timestamp.bat

set TMP_WMIC_OUT=%TEMP%\wmic-output-%TIMESTAMP%-%RANDOM%.txt
echo wmic %*
wmic /output:"%TMP_WMIC_OUT%" %*
cmd /A /C type "%TMP_WMIC_OUT%"
del "%TMP_WMIC_OUT%"

ENDLOCAL