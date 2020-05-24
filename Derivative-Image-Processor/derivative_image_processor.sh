#!/bin/bash

##########################################################################################
#
# Derivative Image Processor (derivative_Image_processor.sh) (c) by Jack Szwergold
#
# Derivative Image Processor is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-02-25, js
# Version: 2014-02-25, js: creation
#          2014-02-25, js: development
#          2014-09-04, js: development
#          2014-09-07, js: development
#          2014-10-09, js: check for non-empty files
#
##########################################################################################

# Set OS specific variables.
if [[ "$OSTYPE" =~ ^darwin ]]; then
  # For OS X
  COPY_PARAMS='-p'
  # STAT_PARAMS='-f %m' # time modified
  STAT_PARAMS='-f %c' # time changed (inode modified)
  LSOF_IGNORE='-c ^Finder -c ^mdworker'
  FIND_OPTIONS='-E' # Find command with 'E'xtended regular expressions.
  FIND_REGEXTYPE='' # Find command.
else
  # For Linux
  COPY_PARAMS='--preserve=timestamps'
  # STAT_PARAMS='-c %Y' # time modified
  STAT_PARAMS='-c %Z' # time changed (inode modified)
  LSOF_IGNORE=''
  FIND_OPTIONS='' # Find command.
  FIND_REGEXTYPE='-regextype posix-extended' # Find command.
fi

LOCK_NAME='DERIVATIVE_IMAGE_PROCESSOR'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./derivative_image_processor.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

##########################################################################################
# Checks to make sure our working environment works.
##########################################################################################

# Checks if ImageMagick 'convert' exists.
hash 'convert' 2>/dev/null || {
  echo >&2 $(date)" - [ERROR: ImageMagick 'convert' not found. Script stopping.]" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

# Checks if ImageMagick 'identify' exists.
hash 'identify' 2>/dev/null || {
  echo >&2 $(date)" - [ERROR: ImageMagick 'identify' not found. Script stopping.]" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

# Checks if the base directory directory exists.
if [ ! -d "${BASE_DIR}" ]; then
  echo $(date)" - [ERROR: Base directory not found. Script stopping.] - "${BASE_DIR} >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit
fi

# Checks if the 'hires' directory exists.
if [ ! -d "${HIRES_IMAGE_DIR}" ]; then
  echo $(date)" - [ERROR: Directory 'hires' not found. Script stopping.] - "${HIRES_IMAGE_DIR} >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit
fi


##########################################################################################
# Function to process full images.
##########################################################################################

process_full_images () {

  # Set the paramters to something that is human readable.
  HIRES_IMAGE_PATH=${1};
  FULL_IMAGE_PATH=${2};

  # Check if the 'full' directory exists. If not, create it.
  if [ ! -d ${FULL_IMAGE_DIR} ]; then
    mkdir -p ${FULL_IMAGE_DIR} & MKDIR_ID=(`jobs -l | awk '{print $2}'`);
    wait ${MKDIR_ID}
  fi

  # Get the image dimensions.
  DIMENSIONS_ARRAY=($(identify -format '%w %h\n' "${HIRES_IMAGE_PATH}"))
  SOURCE_WIDTH=${DIMENSIONS_ARRAY[0]}
  SOURCE_HEIGHT=${DIMENSIONS_ARRAY[1]}
  DIMENSIONS_RATIO=$(expr $SOURCE_WIDTH / $SOURCE_HEIGHT)

  # If the script is running, then set the variable.
  if [[ ${PROCESSED_COUNT} -eq 0 ]]; then
    # Script start time.
    TIMESTAMP_START="$(date +%s)"
    echo $(date)" - [Start Image Process]" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
    wait ${LOGGER_PID}
  fi
  ((PROCESSED_COUNT++))

  # Create a log entry for this.
  echo $(date)" - [Modified: Generating 'full' Image] - ""${BASENAME}" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}

  # 'full'-sized landscape to copy.
  if [[ $DIMENSIONS_RATIO -ge 1 && $SOURCE_WIDTH -eq ${FULL_SIZE_MAX} ]]; then
    # echo 'Copy Landscape:' ${DIMENSIONS_RATIO} ${SOURCE_WIDTH}"x"${SOURCE_HEIGHT} "${HIRES_IMAGE_PATH}";
    nice -n ${NICENESS} cp ${COPY_PARAMS} "${HIRES_IMAGE_PATH}" "${FULL_IMAGE_PATH}" >/dev/null 2>&1 & COPY_ID=(`jobs -l | awk '{print $2}'`);
    wait ${COPY_ID}
  # 'full'-sized portrait to copy.
  elif [[ $DIMENSIONS_RATIO -le 0 && $SOURCE_HEIGHT -eq ${FULL_SIZE_MAX} ]]; then
    # echo 'Copy Portrait:' ${DIMENSIONS_RATIO} ${SOURCE_WIDTH}"x"${SOURCE_HEIGHT} "${HIRES_IMAGE_PATH}";
    nice -n ${NICENESS} cp ${COPY_PARAMS} "${HIRES_IMAGE_PATH}" "${FULL_IMAGE_PATH}" >/dev/null 2>&1 & COPY_ID=(`jobs -l | awk '{print $2}'`);
    wait ${COPY_ID}
  # Resize 'hires' to 'full'.
  else
    # echo 'Resize:' ${DIMENSIONS_RATIO} ${SOURCE_WIDTH}"x"${SOURCE_HEIGHT} "${HIRES_IMAGE_PATH}";
    echo convert "${HIRES_IMAGE_PATH}" ${FULL_RESAMPLE} ${FULL_RESIZE_METHOD} ${FULL_SIZE} ${FULL_QUALITY} ${FULL_SHARPEN} ${OPTIONS} "${FULL_IMAGE_PATH}"
    nice -n ${NICENESS} convert "${HIRES_IMAGE_PATH}" ${FULL_RESAMPLE} ${FULL_RESIZE_METHOD} ${FULL_SIZE} ${FULL_QUALITY} ${FULL_SHARPEN} ${OPTIONS} "${FULL_IMAGE_PATH}" >/dev/null 2>&1 & IMAGEMAGICK_ID=(`jobs -l | awk '{print $2}'`);
    wait ${IMAGEMAGICK_ID}
    sleep ${SLEEPINESS}
  fi

} # process_full_images


##########################################################################################
# Function to process derivative images.
##########################################################################################

process_derivative_images () {

  # Set the paramters to something that is human readable.
  FORCE_CONVERSION=${1:null}

  # Needed for the weird way BASH doesn't handle array indexes.
  DERIVATIVE_ARRAY_COPY=( "${DERIVATIVE_ARRAY[@]}" )

  # for INDEX in $(seq 0 $(expr ${#DERIVATIVE_ARRAY_COPY[*]} - 1 )) # REMOVED 2013-03-11: OS X 10.6.8 doesn't have 'seq'
  for ((INDEX=0; INDEX <= $(expr ${#DERIVATIVE_ARRAY_COPY[*]} - 1); INDEX++)); do

    # Check if the 'derivative' directory exists. If not, create it.
    if [ ! -d ${FINAL_DIR}${DERIVATIVE_ARRAY_COPY[$INDEX]} ]; then
      mkdir -p ${FINAL_DIR}${DERIVATIVE_ARRAY_COPY[$INDEX]} & MKDIR_ID=(`jobs -l | awk '{print $2}'`);
      wait ${MKDIR_ID}
    fi

    # Set the derivative filepath.
    DERIVATIVE_FILEPATH=${FINAL_DIR}${DERIVATIVE_ARRAY_COPY[$INDEX]}"/"${BASENAME}

    # Process the images if the file doesn't exist or the 'FORCE_CONVERSION' option is set.
    if [ ! -f "${DERIVATIVE_FILEPATH}" ] || [ ! -z ${FORCE_CONVERSION} ]; then

      # If the script is running, then set the variable.
      if [[ ${PROCESSED_COUNT} -eq 0 ]]; then
        # Script start time.
        TIMESTAMP_START="$(date +%s)"
        echo $(date)" - [Start Image Process]" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
        wait ${LOGGER_PID}
      fi
      ((PROCESSED_COUNT++))

      echo $(date)" - [Generating '""${DERIVATIVE_ARRAY_COPY[$INDEX]}""' Image] - ""${BASENAME}" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
      wait ${LOGGER_PID}
      nice -n ${NICENESS} convert "${HIRES_IMAGE_PATH}" ${RESAMPLE_ARRAY[$INDEX]} ${RESIZE_METHOD_ARRAY[$INDEX]} ${SIZE_ARRAY[$INDEX]} ${QUALITY_ARRAY[$INDEX]} ${SHARPEN_ARRAY[$INDEX]} ${OPTIONS} "${DERIVATIVE_FILEPATH}" >/dev/null 2>&1 & IMAGEMAGICK_ID=(`jobs -l | awk '{print $2}'`);
      wait ${IMAGEMAGICK_ID}
      sleep ${SLEEPINESS}
    fi
  done

} # process_derivative_images


##########################################################################################
# Core processes begin here.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Checks if the base directory is in use by any process.
  lsof +D ${BASE_DIR} ${LSOF_IGNORE} | grep -q COMMAND &>/dev/null
  if [ $? -eq 0 ]; then
    echo $(date)" - [WARNING: Open files found. Script stopping.] - "${BASE_DIR} >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
    wait ${LOGGER_PID}
    exit
  fi

  # Checks if an image exists in the 'full' directory & not in 'hires' & copy it if needed.
  if [ -d ${FULL_IMAGE_DIR} ]; then
    # for FULL_IMAGE_PATH in ${FULL_IMAGE_DIR}/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
    # for FULL_IMAGE_PATH in $(eval echo ${FULL_IMAGE_DIR}/*.{$FILE_EXTENSIONS}); do
    find ${FIND_OPTIONS} "${FULL_IMAGE_DIR}" -type f ${FIND_REGEXTYPE} -iregex '.*\.('${FILE_EXTENSIONS}')$' \( ! -regex '.*/\..*' \) |\
      while read FULL_IMAGE_PATH;
      do

      if [ -f "${FULL_IMAGE_PATH}" ] && [ -s "${FULL_IMAGE_PATH}" ]; then

        BASENAME=$(basename "${FULL_IMAGE_PATH}")

        # If a hires image does not exist copy it.
        HIRES_IMAGE_PATH=${HIRES_IMAGE_DIR}'/'${BASENAME}

        # Check if the 'hires' directory exists. If not, create it.
        if [ ! -d "${HIRES_IMAGE_DIR}" ]; then
          mkdir -p ${HIRES_IMAGE_DIR} & MKDIR_ID=(`jobs -l | awk '{print $2}'`);
          wait ${MKDIR_ID}
        fi

        # Check if the 'full' directory exists. If not, create it.
        if [ ! -f "${HIRES_IMAGE_PATH}" ]; then
          echo $(date)" - [Missing 'hires' Image: Copying 'full' to 'hires'] - ""${BASENAME}" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
          wait ${LOGGER_PID}
          nice -n ${NICENESS} cp ${COPY_PARAMS} "${FULL_IMAGE_PATH}" "${HIRES_IMAGE_PATH}" & COPY_FULL_ID=(`jobs -l | awk '{print $2}'`);
          wait ${COPY_FULL_ID}
        fi

      fi
    done >/dev/null 2>&1
    sleep ${SLEEPINESS}

  fi
  # exit

  # Now process the hi-res images.
  # for HIRES_IMAGE_PATH in ${HIRES_IMAGE_DIR}/*.{jpg,JPG,jpeg,JPEG,png,PNG}; do
  # for HIRES_IMAGE_PATH in set -- $(eval echo ${HIRES_IMAGE_DIR}/*.{$FILE_EXTENSIONS}); do
  find ${FIND_OPTIONS} "${HIRES_IMAGE_DIR}" -type f ${FIND_REGEXTYPE} -iregex '.*\.('${FILE_EXTENSIONS}')$' \( ! -regex '.*/\..*' \) |\
    while read HIRES_IMAGE_PATH;
    do

    if [ -f "${HIRES_IMAGE_PATH}" ] && [ -s "${HIRES_IMAGE_PATH}" ]; then

      BASENAME=$(basename "${HIRES_IMAGE_PATH}")

      # If a full image does not exist, generate one or copy one.
      FULL_IMAGE_PATH=${FULL_IMAGE_DIR}'/'${BASENAME}

      # Get the modification time of the 'hires' image.
      HIRES_MOD_TIME=$(stat ${STAT_PARAMS} "${HIRES_IMAGE_PATH}" 2> /dev/null);

      # Get the modification time of the 'full' image.
      FULL_MOD_TIME_STAT=$(stat ${STAT_PARAMS} "${FULL_IMAGE_PATH}" 2> /dev/null);

      # FIX: Check if a string is a number or not. Doesn't really work that great.
      if ! [[ "$FULL_MOD_TIME_STAT" =~ ^[0-9]+$ ]]; then
        FULL_MOD_TIME=0
      else
        FULL_MOD_TIME=$FULL_MOD_TIME_STAT
      fi

      # Do a time delta check to see if files should be processed.
      IMAGE_TIME_DELTA=$(expr ${FULL_MOD_TIME} - ${HIRES_MOD_TIME});
      if [[ ${IMAGE_TIME_DELTA} -lt 0 ]]; then

        # Set the file permissions.
        # chmod $CHMOD_FILE "${HIRES_IMAGE_PATH}"

        # Set the group ownership to the file.
        # chgrp ${CHGRP_GROUP} "${HIRES_IMAGE_PATH}"

        # Process the full images.
        process_full_images "${HIRES_IMAGE_PATH}" "${FULL_IMAGE_PATH}"

        # Force the re-processing the derivative images.
        process_derivative_images true
      fi

      # Process the derivative images.
      process_derivative_images

    fi
  # done >/dev/null 2>&1
  done
  sleep ${SLEEPINESS}

  # Log end time.
  echo $(date)" - [End Image Process]" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}

  # Check if 'TIMESTAMP_START' is set & do end calculations if it is.
  if [ ! -z "${TIMESTAMP_START}" ]; then
    # Calculate elapsedtime.
    TIMESTAMP_END="$(date +%s)"
    TIME_ELAPSED="$((TIMESTAMP_END-TIMESTAMP_START))"
    TIME_ELAPSED_FORMATTED=$(printf "%02d:%02d:%02d:%02d\n" "$((TIME_ELAPSED/86400))" "$((TIME_ELAPSED/3600%24))" "$((TIME_ELAPSED/60%60))" "$((TIME_ELAPSED%60))")

    # Log end time.
    echo $(date)" - [Processed Image Count] - ""${PROCESSED_COUNT}" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
    wait ${LOGGER_PID}

    # Log elapsed time.
    echo $(date)" - [Elapsed Time] - ""${TIME_ELAPSED_FORMATTED}" >> ${DERIVATIVE_IMAGE_PROCESSOR_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
    wait ${LOGGER_PID}
  fi

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
