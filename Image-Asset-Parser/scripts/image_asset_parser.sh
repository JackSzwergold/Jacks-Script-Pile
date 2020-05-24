#!/bin/bash

##########################################################################################
#
# Image Asset Parser (image_asset_parser.sh) (c) by Jack Szwergold
#
# Image Asset Parser is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-08-30, js
# Version: 2014-08-30, js: creation
#          2014-08-30, js: development
#
##########################################################################################

# Set OS specific variables.
if [[ "$OSTYPE" =~ ^darwin ]]; then
  # For OS X
  COPY_PARAMS='-p'
  # STAT_PARAMS='-f %m' # time modified
  STAT_PARAMS='-f %c' # time changed (inode modified)
  FIND_OPTIONS='-E' # Find command with 'E'xtended regular expressions.
  FIND_REGEXTYPE='' # Find command.
else
  # For Linux
  COPY_PARAMS='--preserve=timestamps'
  # STAT_PARAMS='-c %Y' # time modified
  STAT_PARAMS='-c %Z' # time changed (inode modified)
  FIND_OPTIONS='' # Find command.
  FIND_REGEXTYPE='-regextype posix-extended' # Find command.
fi

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='IMAGE_ASSET_PARSER_PROCESS'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./image_asset_parser.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

##########################################################################################
# Checks to make sure our working environment actually works.
##########################################################################################

# Checks if 'exiftool' exists.
hash 'exiftool' 2>/dev/null || {
  echo >&2 $(date)" - [ERROR: ExifTool not found. Script stopping.]" >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

# Checks if ImageMagick 'convert' exists.
hash 'convert' 2>/dev/null || {
  echo >&2 $(date)" - [ERROR: ImageMagick 'convert' not found. Script stopping.]" >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

# Checks if ImageMagick 'identify' exists.
hash 'identify' 2>/dev/null || {
  echo >&2 $(date)" - [ERROR: ImageMagick 'identify' not found. Script stopping.]" >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

# Checks if the base script directory exists.
if [ ! -d "${BASE_SCRIPT_DIR}" ]; then
  echo $(date)" - [ERROR: Base script directory not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

# Checks if the base working directory exists.
if [ ! -d "${BASE_WORKING_DIR}" ]; then
  echo $(date)" - [ERROR: Base asset directory not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID};
  exit 1;
fi

# Checks if the source directory exists.
if [ ! -d "${SOURCE_DIR}" ]; then
  echo $(date)" - [ERROR: Source directory not found. Script stopping.] - "${BASE_WORKING_DIR} >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID};
  exit 1;
fi

# Checks if the destination directory exists.
if [ ! -d "${DESTINATION_DIR}" ]; then
  echo $(date)" - [ERROR: Destination directory not found. Script stopping.] - "${BASE_WORKING_DIR} >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID};
  exit 1;
fi

##########################################################################################
# Here is where the magic happens.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Checks if an image exists in the 'full' directory & not in 'hires' & copy it if needed.
  if [ -d ${SOURCE_DIR} ]; then
    find ${FIND_OPTIONS} "${SOURCE_DIR}" -type f ${FIND_REGEXTYPE} -iregex '.*\.('${FILE_EXTENSIONS}')$' \( ! -regex '.*/\..*' \) |\
      while read FULL_IMAGE_PATH;
      do
      if [[ -f "${FULL_IMAGE_PATH}" && "${FULL_IMAGE_PATH}" != *'_thumb'* ]]; then

        # Parse the directory name, extension & filename.
        DIRNAME=$(dirname "${FULL_IMAGE_PATH}")
        BASENAME=$(basename "${FULL_IMAGE_PATH}")
        FILENAME="${BASENAME%.*}"
        EXTENSION="${BASENAME##*.}"

        # Calculate the nested directory fragment & set the final destination directory.
        PATH_FRAGMENT=${FULL_IMAGE_PATH##"${SOURCE_DIR}"}
        PATH_FRAGMENT=$(dirname "${PATH_FRAGMENT#*/*}")
        if [ "${PATH_FRAGMENT}" == "." ]; then
          PATH_FRAGMENT='';
        fi
        if [ ! -z "${PATH_FRAGMENT}" -a "${PATH_FRAGMENT}" != " " ]; then
          if [ ! -d "${DESTINATION_DIR}"'/'"${PATH_FRAGMENT}" ]; then
            mkdir -p "${DESTINATION_DIR}"'/'"${PATH_FRAGMENT}" & MKDIR_PID=(`jobs -l | awk '{print $2}'`);
            wait ${MKDIR_PID}
          fi
          FINAL_DESTINATION_DIR="${DESTINATION_DIR}"'/'"${PATH_FRAGMENT}"
        else
          FINAL_DESTINATION_DIR="${DESTINATION_DIR}"
        fi

        # If the EXIF title has a value, do something.
        if [ true ]; then

          # Create the full path for the thumnail.
          THUMBNAIL="${FINAL_DESTINATION_DIR}"'/'"${FILENAME}"'_thumb.'"${EXTENSION}"

          # Extract the full EXIF data into a JSON file.
          if ${EXPORT_EXIF_JSON_FILE} ; then
            EXIF_JSON_FILE="${FINAL_DESTINATION_DIR}"'/'"${FILENAME}"'_exif.json'
            # If there isn’t an 'EXIF_JSON_FILE', create it.
            if [[ ! -f "${EXIF_JSON_FILE}" ]]; then
              nice -n ${NICENESS} exiftool -json -scanForXMP -a -G1 -s "${FULL_IMAGE_PATH}" > "${EXIF_JSON_FILE}" 2>&1
            fi
          fi

          # Extract the full EXIF data into a TXT file.
          if ${EXPORT_EXIF_TXT_FILE} ; then
            EXIF_TXT_FILE="${FINAL_DESTINATION_DIR}"'/'"${FILENAME}"'_exif.txt'
            # If there isn’t an 'EXIF_TXT_FILE', create it.
            if [[ ! -f "${EXIF_TXT_FILE}" ]]; then
              nice -n ${NICENESS} exiftool -scanForXMP -a -G1 -s "${FULL_IMAGE_PATH}" > "${EXIF_TXT_FILE}" 2>&1
            fi
          fi

          # Extract the full EXIF data into an XML file.
          if ${EXPORT_EXIF_XML_FILE} ; then
            EXIF_XML_FILE="${FINAL_DESTINATION_DIR}"'/'"${FILENAME}"'_exif.xml'
            # If there isn’t an 'EXIF_XML_FILE', create it.
            if [[ ! -f "${EXIF_XML_FILE}" ]]; then
              nice -n ${NICENESS} exiftool -xmlFormat -scanForXMP -a -G1 -s "${FULL_IMAGE_PATH}" > "${EXIF_XML_FILE}" 2>&1
            fi
          fi

          # Generate a thumbnail.
          if ${GENERATE_THUMBNAIL} ; then
            # If there isn’t a thumbnail, create it.
            if [[ ! -f "${THUMBNAIL}" ]]; then
              echo $(date)" - [Generating Thumbnail Image] - ""${BASENAME}" >> ${BASH_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
              wait ${LOGGER_PID}
              nice -n ${NICENESS} convert "${FULL_IMAGE_PATH}" -density '72' -resize '300x300>' -quality '90% '-sharpen '0x1' -colorspace 'sRGB' "${THUMBNAIL}" >/dev/null 2>&1 & IMAGEMAGICK_ID=(`jobs -l | awk '{print $2}'`);
              wait ${IMAGEMAGICK_ID}
              sleep ${SLEEPINESS}
            fi
          fi

          # Pass data to the PHP file.
          if [[ -f "${IMAGE_ASSET_RECEIVER}" ]]; then
            nice -n ${NICENESS} php "${IMAGE_ASSET_RECEIVER}" "${THUMBNAIL}" 2>&1
          fi

        fi

      fi
    # done >/dev/null 2>&1 # suppresses any errors.
    done
  fi
  # exit

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