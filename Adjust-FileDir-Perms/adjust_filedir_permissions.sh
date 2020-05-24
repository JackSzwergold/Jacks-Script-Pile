#!/bin/bash -l

##########################################################################################
#
# Adjust FileDir Permissions (adjust_filedir_permissions.sh) (c) by Jack Szwergold
#
# Adjust FileDir Permissions is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-07-28, js
# Version: 2014-07-28, js: creation
#          2014-09-23, js: development
#          2018-12-25, js: Adjustments to modernize locking process.
#
################################################################################

################################################################################
# Set script values.
script_name=${0##*/};

################################################################################
# Set script locking values.
lock_name_full=${script_name%.*};
lock_name=$(awk -F '-' '{print $1}' <<< ${lock_name_full});
lock_directory='/tmp/'${lock_name}'.lock';
task_pid_path=${lock_directory}'/'${lock_name_full}'.pid';

################################################################################
# Load the configuration file.
################################################################################

# Set the config file.
config_file="./${lock_name}.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${config_file}" ]; then
  source "${config_file}"
else
  echo $(date)" - [ERROR: Configuration file '${config_file}' not found. Script stopping.]" & task_pid=(`jobs -l | awk '{print $2}'`);
  wait ${task_pid}
  exit; # Exit if fails.
fi

################################################################################
# Checks to make sure our working environment works.
################################################################################

if mkdir ${lock_directory} 2>/dev/null; then

  ##############################################################################
  # If the ${lock_directory} doesn't exist, then start working and store the ${task_pid_path}
  echo $$ > ${task_pid_path};

  for DIRECTORY_PATH in "${DIRECTORY_ARRAY[@]}"
  do

    FULL_DIRECTORY_PATH="${DOCUMENT_ROOT}${DIRECTORY_PATH}/"

    if [ -d ${FULL_DIRECTORY_PATH} ]; then

      # Adjust group ownership for all files & directories.
      find ${FULL_DIRECTORY_PATH} ! -group ${CHGRP_GROUP} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chgrp -f ${CHGRP_GROUP} -R ${DOCUMENT_ROOT}${DIRECTORY_PATH}'/' & GROUP_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${GROUP_FIX_PID};

      # Adjust permissions for directories.
      find ${FULL_DIRECTORY_PATH} -type d ! -perm ${CHMOD_DIR} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chmod -f ${CHMOD_DIR} >/dev/null & DIR_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${DIR_PERM_FIX_PID};

      # Adjust permissions for files.
      find ${FULL_DIRECTORY_PATH} -type f ! -perm ${CHMOD_FILE} -not -iwholename '*.git*' -print0 | xargs --no-run-if-empty -0 chmod -f ${CHMOD_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      ##########################################################################
      # Excecutible files.

      # Adjust permissions for PERL files.
      find ${FULL_DIRECTORY_PATH} -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.pl' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for CGI files.
      find ${FULL_DIRECTORY_PATH} -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.cgi' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for SH (shell script) files.
      find ${FULL_DIRECTORY_PATH} -type f ! -perm ${CHMOD_EXEC_FILE} -iwholename '*.sh' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_EXEC_FILE} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      ##########################################################################
      # Drupal settings.

      # Adjust permissions for Drupal settings files.
      find ${FULL_DIRECTORY_PATH} -type f ! -perm ${CHMOD_DRUPAL_SETTINGS} -iwholename '*/settings.php' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_DRUPAL_SETTINGS} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust permissions for the Drupal settings directory.
      find ${FULL_DIRECTORY_PATH} -type d ! -perm ${CHMOD_DRUPAL_DIR} -iwholename '*/sites/default' -print0 | xargs --no-run-if-empty -0 chmod ${CHMOD_DRUPAL_DIR} >/dev/null & FILE_PERM_FIX_PID=(`jobs -l | awk '{print $2}'`);
      wait ${FILE_PERM_FIX_PID};

      # Adjust ownership for specific Drupal directories.
      # find ${FULL_DIRECTORY_PATH} ! -user ${CHGRP_USER} -iwholename '*/sites/default' -print0 | xargs --no-run-if-empty -0 chown ${CHGRP_USER} >/dev/null & USER_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # wait ${USER_FIX_PID};
      # find ${FULL_DIRECTORY_PATH} ! -user ${CHGRP_USER} -iwholename '*/sites/all' -print0 | xargs --no-run-if-empty -0 chown ${CHGRP_USER} >/dev/null & USER_FIX_PID=(`jobs -l | awk '{print $2}'`);
      # wait ${USER_FIX_PID};

    fi

  done

  ##############################################################################
  # With the script done, remove the lock file.
  if ! kill -0 ${task_pid} 2>/dev/null; then
    rm -f ${task_pid_path};
  fi

  ##############################################################################
  # Now check if the lock directory is empty, and if it is remove it.
  if [ -z "$(ls -A ${lock_directory})" ]; then
    rm -rf ${lock_directory};
  fi

else

  if [ -f ${task_pid_path} ] && kill -0 $(cat ${task_pid_path}) 2>/dev/null; then

    ############################################################################
    # Confirm that the process file exists and a process
    # with that PID is truly running.
    echo "Script is Running (PID "$(cat ${task_pid_path})")" >&2;

  else

    ############################################################################
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash, interupt or sudden reboot--then get rid of the PID file
    rm -f ${task_pid_path};

    ############################################################################
    # Now check if the lock directory is empty, and if it is remove it.
    if [ -z "$(ls -A ${lock_directory})" ]; then
      rm -rf ${lock_directory};
    fi

  fi

fi

################################################################################
# And that’s all there is!
exit
