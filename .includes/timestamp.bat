:: Get the timestamp and store it into environment variable "TIMESTAMP"
:: FIXME: depends on the OS version and timezone/locale setting
::set TIMESTAMP=%date:~0,4%-%date:~5,2%-%date:~8,2%.%time:~0,2%-%time:~3,2%-%time:~6,5%
set TIMESTAMP=%DATE:/=-%@%TIME::=-%
