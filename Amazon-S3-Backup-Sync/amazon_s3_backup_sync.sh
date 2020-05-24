#!/bin/bash

##########################################################################################
#
# Amazon S3 Backup Sync (amazon_s3_backup_sync.sh) (c) by Jack Szwergold
#
# Amazon S3 Backup Sync is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2010-01-07, js
# Version: 2010-01-07, js: creation
#          2010-01-07, js: development
#
##########################################################################################

LOCK_NAME="AMAZON_S3_BACKUP_SYNCS"
LOCK_DIR='/tmp/'${LOCK_NAME}'.lock'
PID_FILE=${LOCK_DIR}'/'${LOCK_NAME}'.pid'

AMAZON_CDN_LOCK_NAME="AMAZON_S3_CDN_SYNCS"
AMAZON_CDN_PID_FILE=${LOCK_DIR}'/'${AMAZON_CDN_LOCK_NAME}'.pid';
BANDWIDTH_KBPS=3000

DESTINATION_HOST=""

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  ########################################################################################
  # This is for the 'test_bucket' bucket.
  ########################################################################################

  # Mount the Amazon cloud files 'test_bucket' bucket.
  s3fs 'test_bucket' '/opt/cloud_mounts/amazon/test_bucket';

  # Get the PID of the 's3fs' mount and save it to a file.
  ps -u 'syncuser' | grep s3fs | awk '{ print $1 }' > ${AMAZON_CDN_PID_FILE};

  # Wait for 10 seconds to be sure the bucket mounts.
  sleep 10

  # Sync the Amazon 'test_bucket' bucket to the destination directory.
  rsync -vrupt --bwlimit=${BANDWIDTH_KBPS} '/opt/cloud_mounts/amazon/test_bucket/' ${DESTINATION_HOST}'/opt/test_bucket_syncs/amazon_sync/test_bucket/' >/dev/null 2>&1;

  # Unmount the Amazon cloud files 'test_bucket' bucket using 'kill -TERM' on the PID that spawned it; messy but that is how it works.
  kill -TERM $(cat ${AMAZON_CDN_PID_FILE});

  rm -rf ${LOCK_DIR};
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
