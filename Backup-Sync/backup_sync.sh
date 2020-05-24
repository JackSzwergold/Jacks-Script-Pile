#!/bin/bash

##########################################################################################
#
# Backup Sync (backup_sync.sh) (c) by Jack Szwergold
#
# Backup Sync is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2011-12-01, js
# Version: 2011-12-01, js: creation
#          2014-01-31, js: development
#
##########################################################################################

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='BACKUP_SYNC'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./backup_sync.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

##########################################################################################
# Here is where the magic begins!
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Loop through the backup directory array
  for BACKUP_DEST in "${BACKUP_DEST_ARRAY[@]}"
  do
    # Sync the tar/gzip archives.
    rsync -vtOrupl --bwlimit=${BANDWIDTH_KBPS} --delete-after '/opt/server_backups/'${SERVER_NAME}'_webapps/' ${BACKUP_DEST}':/opt/server_backups/'${SERVER_NAME}'_webapps/' >/dev/null 2>&1
    rsync -vtOrupl --bwlimit=${BANDWIDTH_KBPS} --delete-after '/opt/server_backups/'${SERVER_NAME}'_configs/' ${BACKUP_DEST}':/opt/server_backups/'${SERVER_NAME}'_configs/' >/dev/null 2>&1
    rsync -vtOrupl --bwlimit=${BANDWIDTH_KBPS} --delete-after '/opt/server_db_dumps/'${SERVER_NAME}'_mysql_dumps/' ${BACKUP_DEST}':/opt/server_db_dumps/'${SERVER_NAME}'_mysql_dumps/' >/dev/null 2>&1

    # Straight sync of 'content'
    rsync -vtOrupl --bwlimit=${BANDWIDTH_KBPS} --delete-after '/var/www/content/' ${BACKUP_DEST}':/opt/server_syncs/'${SERVER_NAME}'_sync/content/' >/dev/null 2>&1
  done

  rm -rf ${LOCK_DIR}
  exit
else
  if [ -f ${PID_FILE} ] && kill -0 $(cat ${PID_FILE}) 2>/dev/null; then
    # Confirm that the process file exists & a process
    # with that PID is truly running.
    # echo "Running [PID "$(cat ${PID_FILE})"]" >&2
    exit
  else
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash or sudden reboot--then get rid of the ${LOCK_DIR}
    rm -rf ${LOCK_DIR}
    exit
  fi
fi