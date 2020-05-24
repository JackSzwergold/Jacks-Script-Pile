#!/bin/bash

##########################################################################################
#
# Apache Segfault Watcher (apache_segfault_watcher.sh) (c) by Jack Szwergold
#
# Apache Segfault Watcher is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2013-03-01, js
# Version: 2013-03-01, js: creation
#          2013-03-01, js: development
#          2013-03-05, js: development
#          2014-07-03, js: development
#
##########################################################################################

LOCK_NAME="APACHE_SEGFAULT_WATCHER"
LOCK_DIR=/tmp/${LOCK_NAME}.lock
PID_FILE=${LOCK_DIR}/${LOCK_NAME}.pid

DATE=`date +%Y%m%d`
TIME=`date +%H%M`
# SUFFIX="-"${DATE}"-"${TIME};
SUFFIX="-"${DATE};

APACHE_ERROR_LOG="/var/log/apache2/error.log"
APACHE_RESTART="/etc/init.d/apache2 graceful"
TEXT_TO_WATCH="exit signal Segmentation fault"
# TEXT_TO_WATCH="File does not exist"

HOSTNAME=$(hostname)
MAIL_ADDRESS="email_address@example.com"
MAIL_SUBJECT=${HOSTNAME}": Apache Segfault Notification"
SEND_MAIL_NOTIFICATION=true

SCRIPT_NAME=$(basename "$0")
SCRIPT_BASE_NAME=${SCRIPT_NAME%.*}

# LOG_DIR="/opt/segfault_logs/"
# LOG_FILENAME=${SCRIPT_BASE_NAME}${SUFFIX}".log"
LOG_DIR="/var/log/apache2/"
LOG_FILENAME=${SCRIPT_BASE_NAME}".log"
LOG_FULLPATH=${LOG_DIR}${LOG_FILENAME}

TAIL_NUMLINES=5
FAIL_COUNT=4

# Overrides for tests.
# APACHE_ERROR_LOG="/Users/jack/Desktop/apache_test.log"
# LOG_DIR="/Users/jack/Desktop/"
# LOG_FILENAME=${SCRIPT_BASE_NAME}".log"
# LOG_FULLPATH=${LOG_DIR}${LOG_FILENAME}

# If the Apache log file doesn't exist, then exit.
if [ ! -f ${APACHE_ERROR_LOG} ]; then
  exit
fi

# Main process.
if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  STARTUP_MESSAGE="`date` Log watcher starting."
  if [ -d ${LOG_DIR} ]; then
    echo ${STARTUP_MESSAGE} >> ${LOG_FULLPATH}
  fi

  # Tail--but do not follow--a chunk of the LOG_FULLPATH if the number of instances is
  # greater than or equal to the FAIL_COUNT, act
  if [[ `tail -n ${TAIL_NUMLINES} "${APACHE_ERROR_LOG}" | egrep -c "${TEXT_TO_WATCH}"` -ge ${FAIL_COUNT} ]]; then

    # Create the log message.
    LOG_MESSAGE="`date` Segfault detected on "$HOSTNAME

    # Log the error to the file.
    if [ -d ${LOG_DIR} ]; then
      echo ${LOG_MESSAGE} >> ${LOG_FULLPATH}
    fi

    # Send e-mail notification.
    if ${SEND_MAIL_NOTIFICATION}; then
      echo ${LOG_MESSAGE}$'\n\r'${FAIL_COUNT} | mail -s "${MAIL_SUBJECT}" ${MAIL_ADDRESS}
    fi

    # Restart Apache
    ${APACHE_RESTART}
  fi

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