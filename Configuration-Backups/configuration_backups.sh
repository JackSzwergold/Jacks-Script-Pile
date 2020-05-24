#!/bin/bash

##########################################################################################
#
# Configuration Backups (configuration_backups.sh) (c) by Jack Szwergold
#
# Configuration Backups is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-05-30, js
# Version: 2014-05-30, js: creation
#          2014-05-30, js: development
#
##########################################################################################

LOCK_NAME="CONFIGURATION_BACKUPS"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./configuration_backups.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CHECK_PID}
  exit 1; # Exit if fails.
fi

##########################################################################################
# Core of the script functionality.
##########################################################################################

# Checks if the base backup directory exists.
if [ ! -d "${BACKUP_DIRECTORY}" ]; then
  echo $(date)" - [ERROR: Backup directory was not found. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CHECK_PID}
  exit 1; # Exit if fails.
fi

##########################################################################################
# Core of the script functionality.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

    # Create backup subdirectory.
    mkdir -p ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY};

    # Create the archives of the Apache configs.
    if [ -d ${ETC_DIRECTORY}${APACHE_CONFIG_SUBDIRECTORY} ]; then
      cd ${ETC_DIRECTORY};
      nice -n 19 tar -cf - ${APACHE_CONFIG_SUBDIRECTORY} | gzip > ${BACKUP_DIRECTORY}${PREFIX}${APACHE_CONFIG_NAME}'_configs'${SUFFIX}'.tar.gz';
    fi

    # Create the archives of the Mod Security configs.
    if [ -d ${ETC_DIRECTORY}${MOD_SECURITY_CONFIG_SUBDIRECTORY} ]; then
      cd ${ETC_DIRECTORY};
      nice -n 19 tar -cf - ${MOD_SECURITY_CONFIG_SUBDIRECTORY} | gzip > ${BACKUP_DIRECTORY}${PREFIX}${MOD_SECURITY_CONFIG_NAME}'_configs'${SUFFIX}'.tar.gz';
    fi

    # Copy the PHP 'php.ini' file to the backup directory.
    if [ -s ${PHP_CONFIG} ]; then
      cp ${PHP_CONFIG} ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY}${PREFIX}'php.ini'${SUFFIX};
    fi

    # Copy the MySQL 'my.cnf' file to the backup directory.
    if [ -s ${MYSQL_CONFIG} ]; then
      cp ${MYSQL_CONFIG} ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY}${PREFIX}'my.cnf'${SUFFIX};
    fi

    # Copy the ProFTPD 'proftpd.conf' file to the backup directory.
    if [ -s ${PROFTPD_CONFIG} ]; then
      cp ${PROFTPD_CONFIG} ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY}${PREFIX}'proftpd.conf'${SUFFIX};
    fi

    # Copy the SSH 'ssh_config' file to the backup directory.
    if [ -s ${SSH_CONFIG} ]; then
      cp ${SSH_CONFIG} ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY}${PREFIX}'ssh_config'${SUFFIX};
    fi

    # Copy the SSHD [daemon] 'sshd_config' file to the backup directory.
    if [ -s ${SSHD_CONFIG} ]; then
      cp ${SSHD_CONFIG} ${BACKUP_DIRECTORY}${BACKUP_SUBDIRECTORY}${PREFIX}'sshd_config'${SUFFIX};
    fi

    # Go to the 'backup' directory & compress the configs.
    cd ${BACKUP_DIRECTORY};
    if [ -d ${SERVER_NAME}'_configs-'${DATE} ]; then
      nice -n 19 tar -cf - ${SERVER_NAME}'_configs-'${DATE} | gzip > ${SERVER_NAME}'_configs-'${DATE}'.tar.gz';

      # Delete the backup source directory.
      rm -rf ${SERVER_NAME}'_configs-'${DATE};
    fi

    # Find all Gzip backups that are older than the `expiration` number of days & remove them.
    find ${BACKUP_DIRECTORY} -maxdepth 1 -type f -mtime +${EXPIRATION} -name "*.gz" -exec rm -f {} \;

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

