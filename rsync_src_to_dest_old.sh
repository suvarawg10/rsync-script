#!/bin/bash

# Check if the correct number of arguments is provided
#if [ "$#" -ne 6 ]; then
#    echo "Usage: $0 <rsync-process-name> <src_path> <dest_path> <dest_folder> <dest_user> <dest_port>"
#    exit 1
#fi

if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
    echo "Usage: $0 <rsync-process-name> <src_path> <dest_path> <dest_folder> <dest_user> [<dest_port>]"
    exit 1
fi

# Assign variables based on input arguments
RSYNC_PROCESS_NAME=$1
SRC_PATH=$2
DEST_PATH=$3
DEST_FOLDER=$4
DEST_USER=$5
#DEST_PORT=$6

if [ -z "$6" ]; then
    DEST_PORT=22
else
    DEST_PORT=$6
fi

# Get the current script path
SCRIPT_PATH=$(pwd)
#SCRIPT_PATH=$(dirname "$0")

# Create the log directory if it doesn't exist
LOG_DIR="${SCRIPT_PATH}/log"
if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p "${LOG_DIR}"
else
    # If log directory exists, check if rsync.log exists
    LOG_FILE="${LOG_DIR}/rsync.log"
    if [ -f "${LOG_FILE}" ]; then
        # Take a backup of the existing rsync.log
        BACKUP_LOG_FILE="${LOG_FILE}_bkp_$(date +%Y%m%d%H%M%S)"
        mv "${LOG_FILE}" "${BACKUP_LOG_FILE}"
        echo "Existing log file backed up to ${BACKUP_LOG_FILE}"
    fi
fi

# Define the log file
LOG_FILE="${LOG_DIR}/rsync.log"

rsync -pravhz --dry-run -e "ssh -p ${DEST_PORT}" "${SRC_PATH}" "${DEST_USER}"@"${DEST_PATH}":"${DEST_FOLDER}" &> "${LOG_FILE}"

# Check the log file for errors
if grep -q "error" "${LOG_FILE}"; then
    STATUS="Failure"
    echo "Rsync process '${RSYNC_PROCESS_NAME}' failed. Check the log file at ${LOG_FILE} for details."
    echo "${RSYNC_PROCESS_NAME},${SRC_PATH},${DEST_USER},${DEST_PATH},${DEST_PORT}" > ${SCRIPT_PATH}/${RSYNC_PROCESS_NAME}_Status.log
    exit 1
else
    STATUS="Success"
    echo "${RSYNC_PROCESS_NAME},${SRC_PATH},${DEST_USER},${DEST_PATH},${DEST_PORT}" > ${SCRIPT_PATH}/${RSYNC_PROCESS_NAME}_Status.log
    echo "Rsync process '${RSYNC_PROCESS_NAME}' completed successfully."
fi

