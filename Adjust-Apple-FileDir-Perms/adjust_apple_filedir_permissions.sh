#!/bin/bash

##########################################################################################
#
# Adjust Apple FileDir Permissions (adjust_apple_filedir_permissions.sh) (c) by Jack Szwergold
#
# Adjust Apple FileDir Permissions is licensed under a
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
LOCK_NAME='ADJUST_APPLE_FILEDIR_PERMISSIONS'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./adjust_apple_filedir_permissions.cfg.sh"

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

  for DIRECTORY_NAME in "${DIRECTORY_ARRAY[@]}"
  do

    FULL_DIRECTORY_NAME="${ROOT_DIR_PATH}${DIRECTORY_NAME}"

    if [ -d "${FULL_DIRECTORY_NAME}" ]; then

      # Remove locks from files that are locked.
      if ${DEBUG_MODE}; then
        find "${FULL_DIRECTORY_NAME}" -flags uchg -exec echo "LOCK ISSUES: ""{}" \; & UNLOCK_FILES_PID=(`jobs -l | awk '{print $2}'`);
      else
        find "${FULL_DIRECTORY_NAME}" -flags uchg -exec chflags nouchg "{}" \; & UNLOCK_FILES_PID=(`jobs -l | awk '{print $2}'`);
      fi
      wait ${UNLOCK_FILES_PID};

      # FOR REFERENCE ONLY: Changing user ownership doesn't work well in an ACL environment.
      # Adjust user ownership for all files & directories.
      # find "${FULL_DIRECTORY_NAME}" ! -user ${CHOWN_USER} -exec echo "{}" \; & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # find "${FULL_DIRECTORY_NAME}" ! -user ${CHOWN_USER} -print0 | xargs -0 echo & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # find "${FULL_DIRECTORY_NAME}" ! -user ${CHOWN_USER} -exec chown ${CHOWN_USER} "{}" \; & USER_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # wait ${USER_FIX_PID};

      # Adjust group ownership for all files & directories.
      if ${DEBUG_MODE}; then
        find "${FULL_DIRECTORY_NAME}" ! -group ${CHGRP_GROUP} -exec echo "GROUP ISSUES: ""{}" \; & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      else
        # find "${FULL_DIRECTORY_NAME}" ! -group ${CHGRP_GROUP} -print0 | xargs -0 echo & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
        find "${FULL_DIRECTORY_NAME}" ! -group ${CHGRP_GROUP}  -exec chgrp ${CHGRP_GROUP} "{}" \; & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      fi
      wait ${GROUP_FIX_PID};

      # Adjust permissions for directories.
      if ${DEBUG_MODE}; then
        find "${FULL_DIRECTORY_NAME}" -type d -type d \( ! -name '.*' \) ! -perm ${CHMOD_DIR} -exec echo "DIRECTORY PERMISSIONS: ""{}" \; & DIR_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      else
        # find "${FULL_DIRECTORY_NAME}" -type d -type d \( ! -name '.*' \) ! -perm ${CHMOD_DIR} -print0 | xargs -0 echo & DIR_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
        find "${FULL_DIRECTORY_NAME}" -type d -type d \( ! -name '.*' \) ! -perm ${CHMOD_DIR} -exec chmod -f ${CHMOD_DIR} "{}" \; >/dev/null & DIR_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      fi
      wait ${DIR_PERM_FIX_PID};

      # Adjust permissions for files.
      if ${DEBUG_MODE}; then
        find "${FULL_DIRECTORY_NAME}" -type f -type f \( ! -name '.*' \) ! -perm ${CHMOD_FILE} -exec echo "FILE PERMISSIONS: ""{}" \; & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      else
        # find "${FULL_DIRECTORY_NAME}" -type f -type f \( ! -name '.*' \) ! -perm ${CHMOD_FILE} -print0 | xargs -0 echo & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
        find "${FULL_DIRECTORY_NAME}" -type f -type f \( ! -name '.*' \) ! -perm ${CHMOD_FILE} -exec chmod -f ${CHMOD_FILE} "{}" \; >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      fi
      wait ${FILE_PERM_FIX_PID};

    fi

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
