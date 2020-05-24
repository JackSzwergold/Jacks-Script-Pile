#!/bin/bash

##########################################################################################
#
# URL Content Fetch (url_content_fetch.sh) (c) by Jack Szwergold
#
# URL Content Fetch is licensed under a
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
LOCK_NAME='URL_CONTENT_FETCH'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./url_content_fetch.cfg.sh"

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

  for CONTENT_URL in "${CONTENT_URL_ARRAY[@]}"
  do
    CONTENT_BASENAME=$(basename "${CONTENT_URL}")
    CONTENT_FILENAME="${CONTENT_BASENAME%.*}"
    CONTENT_EXTENSION="${CONTENT_BASENAME##*.}"
    # echo "${CONTENT_FILENAME}"

    # Fetch the data from the URL.
    CONTENT_OUTPUT=$(curl -s -f -m 30 "${CONTENT_URL}");
    if [ ! -z "${CONTENT_OUTPUT}" ]; then
      if [ ! -d "${DESTINATION_PATH}" ]; then
        mkdir -p "${DESTINATION_PATH}" & MKDIR_ID=(`jobs -l | awk '{print $2}'`);
        wait ${MKDIR_ID}
      fi
      echo "${CONTENT_OUTPUT}" >> "${DESTINATION_PATH}"'/'"${CONTENT_FILENAME}""${SUFFIX}"'.txt' & CURL_ID=(`jobs -l | awk '{print $2}'`);
      wait ${CURL_ID}
    fi

    # GZip the content files.
    if [ -d "${DESTINATION_PATH}" ]; then
      find ${DESTINATION_PATH} -maxdepth 1 -type f -mmin +${EXP_MINUTES} -name "${CONTENT_FILENAME}"'-*' -not \( -iname '*.gz' \)| xargs gzip -fq & PATHS_GZIP_PID=(`jobs -l | awk '{print $2}'`);
      wait ${PATHS_GZIP_PID}
    fi

  done >/dev/null 2>&1 # suppresses any errors.
  # done

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
