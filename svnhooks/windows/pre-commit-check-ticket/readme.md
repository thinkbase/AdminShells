pre-commit-check-ticket
====
The Subversion "pre-commit-check" hook to check the commited files and logs, make sure that the commit logs include `#<ticket id>` message.

Deploy(Only for Windows)
----
 1. `cd` `hooks` directory of subversion repository;
 2. Copy `pre-commit.bat` and `pre-commit.js` into hoots directory;
 2. Copy `pre-commit.json.tmpl` into hoots directory, rename it to `pre-commit.json`, then edit this file to change the configuration;

END
----
