#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
	echo "Input Error:sh $0 <rsync-process-name> <src_path> <dest_path> <dest_ip> <dest_user> [<dest_port>]"
    exit 1
fi

# Assign variables based on input arguments
RSYNC_PROCESS_NAME=$1
SRC_PATH=$2
DEST_PATH=$3
DEST_IP=$4
DEST_USER=$5
S_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Check if port is passed, if not, use default port 22
if [ -z "$6" ]; then
    DEST_PORT=22
else
    DEST_PORT=$6
fi

# Get the current script path
SCRIPT_PATH=$(pwd)

# Create the log directory if it doesn't exist
LOG_DIR="${SCRIPT_PATH}/log"
if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p "${LOG_DIR}"
fi

# Define the log file
LOG_FILE="${LOG_DIR}/rsync.log"


# Function to run rsync and check for errors
run_rsync()
{
    echo "=============================================================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Starting rsync process '${RSYNC_PROCESS_NAME}'..."
    echo "=============================================================================="
    # If log file exists, take a backup
    if [ -f "${LOG_FILE}" ]; then
        BACKUP_LOG_FILE="${LOG_FILE}_bkp_$(date +%Y%m%d%H%M%S)"
        mv "${LOG_FILE}" "${BACKUP_LOG_FILE}"
        echo "Existing log file backed up to ${BACKUP_LOG_FILE}"
    fi

    # Run rsync with the provided arguments and log output
    #rsync -pravhO --no-perms --stats -e "ssh -p ${DEST_PORT}" $SRC_PATH $DEST_USER@$DEST_IP:$DEST_PATH > ${LOG_FILE} 2>&1
    rsync -pravhO --stats -e "ssh -p ${DEST_PORT}" $SRC_PATH $DEST_USER@$DEST_IP:$DEST_PATH > ${LOG_FILE} 2>&1
    echo "=============================================================================="
    echo "Stats Below:\n"
    tail -16 ${LOG_FILE}
    echo "=============================================================================="
    echo "Top 5 errors:"
    cat $LOG_FILE | grep 'rsync:' | tail -5
    echo "=============================================================================="
    # Check the log file for errors
    if grep -q "error" "${LOG_FILE}"; then

    echo "=============================================================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Rsync process '${RSYNC_PROCESS_NAME}' failed. Check the log file at ${LOG_FILE} for details."
    echo "=============================================================================="
	return 1
    else

    echo "=============================================================================="
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Rsync process '${RSYNC_PROCESS_NAME}' completed successfully."
    echo "=============================================================================="
    	return 0
    fi
}



# Check if the process is already running
#if pgrep -f "${RSYNC_PROCESS_NAME}" > /dev/null; then
if [ $(pgrep -fc "${RSYNC_PROCESS_NAME}") -gt 1 ]; then
    echo "=============================================================================="
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Rsync process '${RSYNC_PROCESS_NAME}' is already running."
    echo "=============================================================================="
    	exit 1
else
# Initial rsync run and retry until it passes
    # Wait time
    W_TIME=5
    TRIAL_COUNT=1
    while ! run_rsync; do
    echo "=============================================================================="
   	 echo "$(date '+%Y-%m-%d %H:%M:%S'):(Trial #${TRIAL_COUNT}) Retrying rsync process '${RSYNC_PROCESS_NAME}'...After ${W_TIME} Sec."
   	 sleep $W_TIME  # Add a small delay before retrying
	 TRIAL_COUNT=$((TRIAL_COUNT + 1))
    echo "=============================================================================="
    done

    echo "=============================================================================="
    echo "$(date '+%Y-%m-%d %H:%M:%S'),${RSYNC_PROCESS_NAME},${SRC_PATH},${DEST_IP},${DEST_USER},${DEST_PATH},${DEST_PORT}" > ${SCRIPT_PATH}/${RSYNC_PROCESS_NAME}_Status.log
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Rsync process '${RSYNC_PROCESS_NAME}' finished."
    echo "=============================================================================="
fi
