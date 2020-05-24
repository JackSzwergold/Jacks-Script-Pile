#!/bin/bash

##########################################################################################
#
# Report Disk Usage (report_disk_usage.sh) (c) by Jack Szwergold
#
# Report Disk Usage is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-06-12, js
# Version: 2014-06-12, js: creation
#          2014-10-31, js: development
#
##########################################################################################

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='REPORT_DISK_USAGE'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./report_disk_usage.cfg.sh"

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

  # START: Loop through the parent directory name.
  for PARENT_DIRECTORY_NAME in "${DIRECTORY_ARRAY[@]}"
  do

    FULL_DIRECTORY_NAME="${ROOT_DIR_PATH}/${PARENT_DIRECTORY_NAME}"

    # START: Find directories in the child directories.
    find "${FULL_DIRECTORY_NAME}" -maxdepth 1 -type d \( ! -name '.*' -and ! -name '@*' \) |\
      while read DIRECTORY_NAME
      do

        if [[ "${DIRECTORY_NAME}" != "${FULL_DIRECTORY_NAME}" ]]; then

          # Parse the directory name, extension & filename.
          DIRNAME=$(dirname "${DIRECTORY_NAME}")
          BASENAME=$(basename "${DIRECTORY_NAME}")
          BASENAME="${BASENAME// /_}"
          # FILENAME="${BASENAME%.*}"
          # EXTENSION="${BASENAME##*.}"
          
          LOG_DATE=`date +%Y%m%d`;
          LOG_TIME=`date +%H%M%S`;
          LOG_SUFIX="-"${LOG_DATE}"-"${LOG_TIME};

          LOG_OUTPUT_FILE="${LOG_PREFIX}-${BASENAME}${LOG_SUFIX}.csv";
          LOG_OUTPUT_DIRECTORY="${LOG_PATH}${LOG_PREFIX}-${LOG_DIR_SUFIX}"
          LOG_OUTPUT_FULLPATH="${LOG_OUTPUT_DIRECTORY}/${LOG_OUTPUT_FILE}"

          if [ ! -d "${LOG_OUTPUT_DIRECTORY}" ]; then
            mkdir -p "${LOG_OUTPUT_DIRECTORY}" & MKDIR_PID=(`jobs -l | awk '{print $2}'`);
            wait ${MKDIR_PID};
          fi

          # START: Find files.
          find "${DIRECTORY_NAME}" -maxdepth ${FIND_MAXDEPTH} -type f -mtime ${FIND_MTIME} -size ${FIND_SIZE} |\
            while read FULL_ITEM_PATH
            do
              echo "${FULL_ITEM_PATH}"
 
              CHECK_DATE=`date +%Y-%m-%d`;
              CHECK_TIME=`date +%H:%M:%S`;

              FILE_DIRNAME=$(dirname "${FULL_ITEM_PATH}");
              FILE_BASENAME=$(basename "${FULL_ITEM_PATH}");

              # Get the modified date & time.
              if [[ "$OSTYPE" =~ ^darwin ]]; then
                MODIFIED_ARRAY=($(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${FULL_ITEM_PATH}"));
              else
                MODIFIED_ARRAY=($(stat -c '%.19y' "${FULL_ITEM_PATH}"));
              fi
              MODIFIED_DATE=${MODIFIED_ARRAY[0]};
              MODIFIED_TIME=${MODIFIED_ARRAY[1]};

              # Get the changed date & time.
              if [[ "$OSTYPE" =~ ^darwin ]]; then
                CHANGED_ARRAY=($(stat -f "%Sc" -t "%Y-%m-%d %H:%M:%S" "${FULL_ITEM_PATH}"));
              else
                CHANGED_ARRAY=($(stat -c '%.19z' "${FULL_ITEM_PATH}"));
              fi
              CHANGED_DATE=${CHANGED_ARRAY[0]};
              CHANGED_TIME=${CHANGED_ARRAY[1]};

              # Calculate the MD5 value.
              FILE_SIZE=$(stat "${STAT_FILE_SIZE}" "${FULL_ITEM_PATH}");
              FILE_SIZE="${FILE_SIZE// /}"; # Do this to get rid of unwanted whitespace.

              # Log the data.
              echo \""${DIRECTORY_NAME}"\",\""${CHECK_DATE}"\",\""${CHECK_TIME}"\",\""${FILE_SIZE}"\",\""${FILE_BASENAME}"\",\""${FILE_DIRNAME}"\",\""${MODIFIED_DATE}"\",\""${MODIFIED_TIME}"\",\""${CHANGED_DATE}"\",\""${CHANGED_TIME}"\" >> "${LOG_OUTPUT_FULLPATH}";

            done # END: Find files.

        fi

    done # END: Find directories in the child directories.

  done # END: Loop through the parent directory name.

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
