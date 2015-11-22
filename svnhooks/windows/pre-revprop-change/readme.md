pre-revprop-change-4-windows
====
The Subversion "pre-revprop-change" hook to make client can modify the commit logs, just for Windows.

Deploy(Only for Windows)
----
 1. `cd` `hooks` directory of subversion repository;
 2. Copy `pre-revprop-change.bat` and `pre-revprop-change.js` into hoots directory;

Modification Logs
----
This script should log modification information into `/logs-pre-revprop-change/[revision].log` in subversion repository;

for example:
```
    ==== Start revprop-change ====
    2015-01-21 05:02:34
    pass = true
    -------- Original log --------
    For testing svn log change.
    002 003
    ------ Changing context ------
    repository: D:\test\svn-log-test\repo
    revision  : 1
    user      : root
    property  : svn:log
    action    : M
    ----------- Finish -----------


    ==== Start revprop-change ====
    2015-01-21 05:02:42
    pass = true
    -------- Original log --------
    For testing svn log change.
    002 003 004
    ------ Changing context ------
    repository: D:\test\svn-log-test\repo
    revision  : 1
    user      : root
    property  : svn:log
    action    : M
    ----------- Finish -----------
```

END
----
