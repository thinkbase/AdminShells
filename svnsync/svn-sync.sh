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

# Define SITE_BASE
set +o nounset
if [ -z $SITE_BASE ]; then
    SITE_BASE=$(cd "$_script_dir/."; pwd)
fi
set -o nounset

for CFG in `ls "${SITE_BASE}/conf.d/"`
do
    echo -e "\n================================================================================"
    echo "Start SVN [${CFG}] at `date "+%Y%m%d-%H%M%S"`"
    set -x
    source "${SITE_BASE}/conf.d/${CFG}"
    set +x
    echo "_REPO_DIR = ${_REPO_DIR}, _SVN_URL = ${_SVN_URL}"
    echo -e "================================================================================"
    FULL_REPO_DIR=${SITE_BASE}/repo/${_REPO_DIR}
    if [ ! -d "${FULL_REPO_DIR}" ]
    then
        echo "${_REPO_DIR} not initialized, begin to initialize ..."
        set -x
        mkdir -p "${FULL_REPO_DIR}"
        svnadmin create "${FULL_REPO_DIR}"
        create_revprop_change_hook "${FULL_REPO_DIR}"
        set +x
        svnsync initialize --source-username=${_SVN_SYNC_U} --source-password=${_SVN_SYNC_P} file://${FULL_REPO_DIR} ${_SVN_URL}
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
    # SVN Sync
    set +x
    svnsync sync --source-username=${_SVN_SYNC_U} --source-password=${_SVN_SYNC_P} file:///${FULL_REPO_DIR}
    echo "Sync SVN [${CFG}] finished at `date "+%Y%m%d-%H%M%S"`"
    echo -e "================================================================================"
done