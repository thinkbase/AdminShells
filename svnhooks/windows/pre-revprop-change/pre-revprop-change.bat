svnlook log "%1" -r %2 | cscript "%1/hooks/pre-revprop-change.js" //Nologo %1 %2 %3 %4 %5
EXIT %ERRORLEVEL% 
