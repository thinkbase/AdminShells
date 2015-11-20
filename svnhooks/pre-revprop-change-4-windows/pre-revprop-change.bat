set TMP_FILE=%TEMP%\pre-revprop-change.%RANDOM%
svnlook log "%1" -r %2 > "%TMP_FILE%"
cscript "%1/hooks/pre-revprop-change.js" //B %1 %2 %3 %4 %5 "%TMP_FILE%"