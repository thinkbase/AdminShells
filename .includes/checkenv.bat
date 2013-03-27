:: Testing environment variable, and show error message if not exist
:: arguments: %1 - environment variable name, %2 - error message
IF defined %1 (
    set CHECKENV_ERRCODE=0
) Else (
    echo ENV Variable %1 missing - %2
    set CHECKENV_ERRCODE=-1
)
