sh rsync_src_to_dest.sh test /tmp/ /tmp2/tmp/ 10.15.15.223 appadmin 22
=================================================================================================
=================================================================================================

Rsync Source to Destination Script
Overview
This script automates the process of synchronizing files and directories from a source location to a destination location using rsync. It handles retries in case of failures, ensures only one instance of the process runs at a time, and logs the process details including the number of trials.

Usage
sh rsync_src_to_dest.sh <rsync-name> <src_path> <dest_path> <dest_folder> <dest_user> [<dest_port>]

<rsync-process-name>: A unique name for the rsync process.
<src_path>: The source directory path to be synchronized.
<dest_path>: The destination directory path on the remote server.
<dest_folder>: The folder name within the destination path.
<dest_user>: The username for the remote server.
[<dest_port>]: (Optional) The SSH port for the remote server. Defaults to 22 if not provided.

**Features**

Retry Mechanism: Automatically retries the rsync process until it succeeds.

Logging: Logs all activities and errors in a log file located in a log directory created in the script's directory.

Backup Log: Backs up the existing log file before starting a new run.

Single Instance: Ensures that only one instance of the process is running at any time.

Trial Count: Tracks and logs the number of trials it takes for the rsync process to succeed.

**Prerequisites**
Ensure you have rsync and ssh installed on your system.
Ensure you have the necessary permissions to run the script and access the source and destination paths.
Passwordless SSH Setup
-------------------------------------------------------------------
To enable passwordless SSH access, follow these steps:
Generate SSH Key Pair (if not already generated):
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
Press Enter to accept the default file location and provide a passphrase if desired.
Copy SSH Key to Remote Server
ssh-copy-id -i ~/.ssh/id_rsa.pub <dest_user>@<dest_path>
Replace <dest_user> and <dest_path> with the remote server's username and address.
Verify SSH Key Authentication:
ssh <dest_user>@<dest_path>
---------------------------------------------------------------
***Instructions***:

Clone or download the script to your local machine.

Make the script executable:
sh chmod +x rsync_src_to_dest.sh

Run the script with the required arguments:

sh rsync_src_to_dest.sh <rsync-process-name> /path/to/source /path/to/destination dest_folder dest_user [dest_port]

Example
./rsync_src_to_dest.sh my_rsync_process /home/user/source /var/www/html destination_folder remote_user 2222

Script Details

Variables:-
RSYNC_PROCESS_NAME: The name of the rsync process.
SRC_PATH: Source path to be synchronized.
DEST_PATH: Destination path on the remote server.
DEST_FOLDER: Folder name within the destination path.
DEST_USER: Username for the remote server.
DEST_PORT: SSH port for the remote server (defaults to 22).
SCRIPT_PATH: The directory path of the script.
LOG_DIR: Directory for storing log files.
LOG_FILE: Path to the log file.
TRIAL_COUNT: Counter for the number of rsync trials.

Functions:-
**run_rsync: Executes the rsync command and logs the output. Checks for errors and returns the status.
Process

**Initial Setup:
Checks if the correct number of arguments is provided.
Assigns variables based on input arguments.
Sets up the log directory and file.
Ensures only one instance of the process is running.

**Rsync Execution:
Runs the rsync command and logs the output.
Checks for errors and retries if necessary, incrementing the trial count each time.

**Completion:
Logs the final status including the number of trials.

**Logging
Logs are stored in the log directory within the script's directory. Each run generates a new log file, with old logs being backed up with a timestamp
