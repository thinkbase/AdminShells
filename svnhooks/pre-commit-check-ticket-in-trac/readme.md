pre-commit-check-ticket-in-trac
====
The Subversion "pre-commit" hook to check comment text format and bind to trac ticket.

Deploy(On Linux)
----
 1. `cd` `hook` directory of subversion repository;
 2. `ln -s` `pre-commit` script file into `hook` directory;
 3. create `pre-commit.conf` in `hook` directory, as the following examples;
    - A general example:
        ````
# Error messages for comment format error and ticket invalid error
CONF_ERR_MSG_FORMAT="SVN comment format invalid, must match: '#<ticket> <comments>'"
CONF_ERR_MSG_TICKET="Ticket number invalid, may Ticket not existed, or been fixed, closed, rejected"
# The trac db (sqlite) to check ticket number
CONF_TRAC_DB="/data/tracenv/project1/db/trac.db"
        ````
    - A Chinese example:
    ````
# Error messages for comment format error and ticket invalid error
CONF_ERR_MSG_FORMAT="SVN comment 无效，必须符合格式: '#<ticket> <comments>'"
CONF_ERR_MSG_TICKET="Ticket 编号无效，可能 Ticket 不存在，或者已经被 fix、close 或 reject"
# The trac db (sqlite) to check ticket number
CONF_TRAC_DB="/data/tracenv/project1/db/trac.db"
    ````

END
----
