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

TIMESTAMP=`date "+%Y%m%d-%H%M%S"`

echo -e '\n[Usage] $1 - source directory; $2 - target directory .\n'
SRC_DIR="$1"
TGT_DIR="$2"

# Check1 - source directory MUST exists
if [ ! -d "${SRC_DIR}" ]
then
    echo "[ERROR -1] source directory not exists."
    exit -1;
fi

# Check2 - source directory not initialized, but target directory exists already
if [ ! -d "${SRC_DIR}/.git" ]
then
    if [ -d "${TGT_DIR}" ]
    then
        echo "[ERROR -2] source directory not initialized, but target directory exists already."
        echo "* The backup program($0) should create target directory automaticly, please DON'T create target directory manually."
        exit -2;
    fi
fi

# Check3 - source directory initialized, but target directory not initialized
if [ -d "${SRC_DIR}/.git" ]
then
    if [ ! -d "${TGT_DIR}/refs/heads/" ]
    then
        echo "[ERROR -3] source directory initialized, but target directory not initialized."
        echo "* The source directory MUST NOT be a git repository before backup initialization."
        exit -3;
    fi
fi

# If source directory not initialized, create target directory(repo) and initialize source directory
if [ ! -d "${SRC_DIR}/.git" ]
then
    if [ ! -d "${TGT_DIR}" ]
    then
        echo "[INIT] source directory not initialized, create target directory(repo) and initialize source directory ..."
        set -x
        git init --bare "${TGT_DIR}"
        git clone "${TGT_DIR}" "/tmp/git-backup-${TIMESTAMP}"
        mv -v "/tmp/git-backup-${TIMESTAMP}/.git" "${SRC_DIR}"
        rmdir "/tmp/git-backup-${TIMESTAMP}"
        set +x
    fi
fi

# Commit and push
if [ -d "${SRC_DIR}/.git" ]
then
    if [ -d "${TGT_DIR}/refs/heads/" ]
    then
        echo "[BACKUP] ${SRC_DIR} --> ${TGT_DIR} ..."
        set -x
        pushd "${SRC_DIR}"
        git config user.email "backup@bokesoft.com"
        git config user.name "backup"
        git config push.default simple
        git add --all .
        set +o errexit  # commit should return non-zero if nothing could commit
        git commit -m "backup `date "+%Y%m%d-%H%M%S"`"
        set -o errexit
        git push
        git status
        git ls-files -o
        popd
        set +x
        exit 0;
    fi
fi

# Exception
echo "[ERROR -9] Exception!"
echo "* Unknown exception, please check shell script: $0."
exit -9;

