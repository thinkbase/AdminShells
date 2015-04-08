#!/bin/bash

# Call other program(always batch file) and log stdout/stderr into log file
# Syntax: batch-shell.sh [/daily] <command line>
#   /daily - use one log file per day(default is one file every time running the command line)

set -o nounset
set -o errexit

# Get the directory of current shell, so we can calculate the "PortableTrac" path in git repo.
if [ -z $BASH ]; then
    echo "This shell script MUST run under bash."
    exit /b -1
fi
_script="$(readlink -f "${BASH_SOURCE[0]}")"
_script_dir="$(dirname "$_script")"
echo "Directory of $_script : $_script_dir"

# Define BATCH_SHELL_LOG_DIR
set +o nounset
if [ -z "$BATCH_SHELL_LOG_DIR" ]; then
    BATCH_SHELL_LOG_DIR="$(dirname "$_script_dir/..")/.logs"
fi
set -o nounset

# Define current timestamp
TIMESTAMP=`date "+%Y%m%d-%H%M%S"`

# Begin to run ...
CMD_LINE=$*
PROG_NAME=$1
CUR_DATE=$TIMESTAMP
if [ "$1" = "/daily" ]
then
    CUR_DATE=`date "+%Y%m%d"`

    # trim "/daily "
    CMD_LINE=${CMD_LINE:7}
    PROG_NAME=$2
fi

# CMD_LINE may contain directory
PROG_NAME=${PROG_NAME//\//_}
# remove double quotes, such as "C:\Program Files\Java\jre6\bin\java"
PROG_NAME=${PROG_NAME//\"/}

mkdir -p "${BATCH_SHELL_LOG_DIR}"

LOG_FILE="$BATCH_SHELL_LOG_DIR/$PROG_NAME.$CUR_DATE.log"

echo "Run [$*] at $TIMESTAMP , with log file $LOG_FILE ..."

echo -e "\n" >> "$LOG_FILE"
echo "********************************************************************************" >> "$LOG_FILE"
echo "*                                                                              *" >> "$LOG_FILE"
echo "*  Begin to run [$CMD_LINE] ..."                                                  >> "$LOG_FILE"
echo "*   - User    : `whoami`"                                                         >> "$LOG_FILE"
echo "*   - Time    : `date`"                                                           >> "$LOG_FILE"
echo "*   - Log file: $LOG_FILE"                                                        >> "$LOG_FILE"
echo "*                                                                              *" >> "$LOG_FILE"
echo "********************************************************************************" >> "$LOG_FILE"
echo -e "\n" >> "$LOG_FILE"

bash -c "$CMD_LINE >> \"$LOG_FILE\" 2>&1"
set +x

echo -e "\n" >> "$LOG_FILE"
echo "********************************************************************************" >> "$LOG_FILE"
echo "*                                                                              *" >> "$LOG_FILE"
echo "*  Run [$CMD_LINE] completed, `date` ."                                           >> "$LOG_FILE"
echo "*                                                                              *" >> "$LOG_FILE"
echo "********************************************************************************" >> "$LOG_FILE"
echo -e "\n\n\n" >> "$LOG_FILE"

