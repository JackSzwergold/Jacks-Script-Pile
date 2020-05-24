#!/bin/bash

##########################################################################################
#
# MD5 Checksum Process (md5_checksum_process.sh) (c) by Jack Szwergold
#
# MD5 Checksum Process is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2013-10-07, js
# Version: 2013-10-07, js: creation
#          2013-10-07, js: development
#          2014-09-13, js: development
#
##########################################################################################

# Set OS specific variables.

if [[ "$OSTYPE" =~ ^darwin ]]; then
  # For OS X
  MD5_COMMAND='md5 -r' # Command for the the MD5 util.
  STAT_FILE_SIZE='-f %z' # Stat params to get the file size.
  FIND_OPTIONS='-E' # Find command with 'E'xtended regular expressions.
  FIND_REGEXTYPE='' # Find command.
else
  # For Linux
  MD5_COMMAND='md5sum' # Command for the the MD5 util.
  STAT_FILE_SIZE='-c %s' # Stat params to get the file size.
  FIND_OPTIONS='' # Find command.
  FIND_REGEXTYPE='-regextype posix-extended' # Find command.
fi

LOCK_NAME='MD5_CHECKSUMS'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'


##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./md5_checksum_process.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi


##########################################################################################
# A simple 'in_array' function for bash.
# SOURCE: http://mykospark.net/tag/in_array/
##########################################################################################

function in_array() {
  local x
  ENTRY=$1
  shift 1
  ARRAY=( "$@" )
  [ -z "${ARRAY}" ] && return 1
  [ -z "${ENTRY}" ] && return 1
  for x in ${ARRAY[@]}; do
    [ "${x}" == "${ENTRY}" ] && return 0
  done
  return 1
} # in_array


##########################################################################################
# Function to do the MD5 checks.
##########################################################################################

do_the_md5_checks () {

  # Set the paramters to something that is human readable.
  FULL_ITEM_PATH=${1};
  DIRECTORY_NAME=${2};
  CSV_OUTPUT_FULLPATH=${3};

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

  # Get the file size.
  MD5_VALUE=$(nice -n ${NICENESS} ${MD5_COMMAND} "${FULL_ITEM_PATH}" | awk '{ print $1 }');

  # Calculate the MD5 value.
  FILE_SIZE=$(stat "${STAT_FILE_SIZE}" "${FULL_ITEM_PATH}");
  FILE_SIZE="${FILE_SIZE// /}"; # Do this to get rid of unwanted whitespace.

  # Log the data.
  echo \""${DIRECTORY_NAME}"\",\""${CHECK_DATE}"\",\""${CHECK_TIME}"\",\""${MD5_VALUE}"\",\""${FILE_SIZE}"\",\""${FILE_BASENAME}"\",\""${FILE_DIRNAME}"\",\""${MODIFIED_DATE}"\",\""${MODIFIED_TIME}"\",\""${CHANGED_DATE}"\",\""${CHANGED_TIME}"\" >> "${CSV_OUTPUT_FULLPATH}";

} # do_the_md5_checks


##########################################################################################
# Core processes begin here.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Create an array of all top level folders in the directory.
  unset DIRECTORY_ARRAY DIRECTORY_INDEX
  while IFS= read -r -u3 -d $'\0' file; do
    DIRECTORY_NAME=$(echo "${file}" | sed 's!.*/!!');
    if [[ ! -z "${DIRECTORY_NAME}" && "${ROOT_PATH}" != "${DIRECTORY_NAME}" ]] ; then
      DIRECTORY_ARRAY[DIRECTORY_INDEX++]="${DIRECTORY_NAME}";
    fi
  done 3< <(find "${ROOT_PATH}" -maxdepth 1 -type d \( ! -regex '.*/\..*' \) -print0)

  for DIRECTORY_NAME in "${DIRECTORY_ARRAY[@]}"; do

    # Set the directory path.
    DIRECTORY_PATH="${ROOT_PATH}${DIRECTORY_NAME}";

    # Check if the directory exists. If so, do something.
    if [ -d "${DIRECTORY_PATH}" ]; then

      # Start time & date.
      # echo 'START: ' `date`;

      LOG_DATE=`date +%Y%m%d`;
      LOG_TIME=`date +%H%M%S`;
      LOG_SUFFIX="-"${LOG_DATE}"-"${LOG_TIME};

      CSV_OUTPUT_FILE='md5_report_'"${DIRECTORY_NAME// /-}"${LOG_SUFFIX}'.csv';
      CSV_OUTPUT_FULLPATH="${CSV_OUTPUT_PATH}""${CSV_OUTPUT_FILE}"

      # Set the column headers for the CSV file.
      echo directory_name,check_date,check_time,md5_value,file_size,file_name,directory_name,modified_date,modified_time,changed_date,changed_time >> "${CSV_OUTPUT_FULLPATH}";

      if in_array "${CHECK_ALL_DIRECTORY_CONTENT}" "${DIRECTORY_NAME}"; then
        echo "${DIRECTORY_NAME}" '- VIA ALL FILES'
        # Find files via file extensions.
        find "${DIRECTORY_PATH}" -type f \( ! -regex '.*/\..*' \) |\
          while read FULL_ITEM_PATH; do
            if [ -f "${FULL_ITEM_PATH}" ]; then
              do_the_md5_checks "${FULL_ITEM_PATH}" "${DIRECTORY_NAME}" "${CSV_OUTPUT_FULLPATH}"
            fi
          # done >/dev/null 2>&1
          done
      else
        echo "${DIRECTORY_NAME}" '- VIA EXTENSION'
        # Find files via file extensions.
        find ${FIND_OPTIONS} "${DIRECTORY_PATH}" -type f ${FIND_REGEXTYPE} -iregex '.*\.('${FILE_EXTENSIONS}')$' \( ! -regex '.*/\..*' \) |\
          while read FULL_ITEM_PATH; do
            if [ -f "${FULL_ITEM_PATH}" ]; then
              do_the_md5_checks "${FULL_ITEM_PATH}" "${DIRECTORY_NAME}" "${CSV_OUTPUT_FULLPATH}"
            fi
          # done >/dev/null 2>&1
          done
      fi
    fi

    # End time & date.
    # echo 'END: ' `date`;
  done

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
