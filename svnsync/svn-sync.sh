#! /bin/bash
if [ -z $BASH ]; then
    echo "This shell script MUST run under bash."
    exit -1
fi
_script="$(readlink -f "${BASH_SOURCE[0]}")"
_script_dir="$(dirname "$_script")"
echo "Directory of $_script : $_script_dir"

set -o nounset
set -o errexit

function create_revprop_change_hook()
{
cat <<'EOF' > "$1/hooks/pre-revprop-change"
#!/bin/sh
exit 0
EOF

chmod +x "$1/hooks/pre-revprop-change"
}

# Define SVN_SYNC_BASE
set +o nounset
if [ -z $SVN_SYNC_BASE ]; then
    SVN_SYNC_BASE=$(cd "$_script_dir/."; pwd)
fi
set -o nounset

# Read .passwd.rc, to get confidential variables such as username or password.
if [ -f "${SVN_SYNC_BASE}/conf.d/.passwd.rc" ]
then
    echo -e "\n*** Reading confidential variables from ${SVN_SYNC_BASE}/conf.d/.passwd.rc ..."
    set +x
    source "${SVN_SYNC_BASE}/conf.d/.passwd.rc"
fi

# Run echo config and do sync
for CFG in `ls "${SVN_SYNC_BASE}/conf.d/"`
do
    echo -e "\n================================================================================"
    echo "Start SVN [${CFG}] at `date "+%Y%m%d-%H%M%S"`"
    set -x
    source "${SVN_SYNC_BASE}/conf.d/${CFG}"
    set +x
    echo "_REPO_DIR = ${_REPO_DIR}, _SVN_URL = ${_SVN_URL}"
    echo -e "================================================================================"
    FULL_REPO_DIR=${SVN_SYNC_BASE}/repo/${_REPO_DIR}
    if [ ! -d "${FULL_REPO_DIR}" ]
    then
        echo "${_REPO_DIR} not initialized, begin to initialize ..."
        set -x
        mkdir -p "${FULL_REPO_DIR}"
        svnadmin create "${FULL_REPO_DIR}"
        create_revprop_change_hook "${FULL_REPO_DIR}"
        set +x
        svnsync initialize --non-interactive --source-username=${_SVN_SYNC_U} --source-password=${_SVN_SYNC_P} file://${FULL_REPO_DIR} ${_SVN_URL}
    fi
    echo "${_REPO_DIR}: begin to sync ..."
    # To prevent svnsync run twice or more
    INSTANCE_COUNT=`ps -ef | grep svnsync | grep -F "${FULL_REPO_DIR}" | grep -v "grep" | wc -l`
    if [ $INSTANCE_COUNT -gt 0 ]
    then
        echo "Another svnsync instance found: ${FULL_REPO_DIR}, exit."
        exit -1
    fi
    set -x
    # Clean sync lock(caused by svnsync exit unexpected)
    svn propdel svn:sync-lock --revprop -r0 file:///${FULL_REPO_DIR}
    # Change the source url, to change souece url automatically
    svn propset svn:sync-from-url --revprop -r0 ${_SVN_URL} file:///${FULL_REPO_DIR}
    set +x
    # SVN Sync (Use set +x to hide password in command line)
    set +x
    echo "svnsync sync --non-interactive --source-username=*** --source-password=*** file:///${FULL_REPO_DIR} ..."
    svnsync sync --non-interactive --source-username=${_SVN_SYNC_U} --source-password=${_SVN_SYNC_P} file:///${FULL_REPO_DIR}
    echo "Sync SVN [${CFG}] finished at `date "+%Y%m%d-%H%M%S"`"
    echo -e "================================================================================"
done
