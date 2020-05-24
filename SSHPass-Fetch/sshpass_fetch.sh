#!/bin/bash

##########################################################################################
#
# SSHPass Fetch (sshpass_fetch.sh) (c) by Jack Szwergold
#
# SSHPass Fetch is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-02-13, js
# Version: 2014-02-13, js: creation
#          2014-02-19, js: development
#
##########################################################################################

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='SSHPASS_FETCH'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./sshpass_fetch.cfg.sh"

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

  # Use sshpass and scp to copy the production version of the 'paths' file.
  sshpass -p "${SOURCE_PASSWORD}" scp -p "${SOURCE_CONNECTION}"':'"${SOURCE_PATH}" "${DESTINATION_FULL}"

  # Find the old 'paths' files & dump them.
  find ${DESTINATION_PATH} -maxdepth 1 -type f -mmin +${EXP_MINUTES} -name "paths-*" | sort -nr | tail -n +18 | xargs rm -f & PATHS_COPY_PID=(`jobs -l | awk '{print $2}'`);
  wait ${PATHS_COPY_PID}

  # GZip the 'paths' files.
  find ${DESTINATION_PATH} -maxdepth 1 -type f -mmin +${EXP_MINUTES} -name "paths-*" -not \( -iname '*.gz' \)| xargs gzip -fq & PATHS_GZIP_PID=(`jobs -l | awk '{print $2}'`);
  wait ${PATHS_GZIP_PID}

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
