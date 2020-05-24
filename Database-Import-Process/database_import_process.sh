#!/bin/bash

##########################################################################################
#
# Database Import Process (database_import_process.sh) (c) by Jack Szwergold
#
# Database Import Process is licensed under a
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

LOCK_NAME="DB_IMPORT_PROCESS"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./database_import_process.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
  wait ${CHECK_PID}
  exit 1; # Exit if fails.
fi

##########################################################################################
# Checks to make sure our working environment works.
##########################################################################################

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  if [ -f ${DATABASE_DUMP_DIR}${MOST_RECENT_DATABASE} ]; then

    # Test to see if the file has the correct extension
    if [ ${MOST_RECENT_DATABASE: -7} != ${DATABASE_FILE_EXTENSION} ]; then
      echo $(date)" - [ERROR: Incorrect extension on import file. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
      wait ${CHECK_PID}
      exit 1; # Exit if fails.
    fi

    # Test of the GZIP file is valid & undamaged.
    DATABASE_FULLPATH=${DATABASE_DUMP_DIR}${MOST_RECENT_DATABASE}
    GZIP_TEST=$(`gunzip -t ${DATABASE_FULLPATH}`);
    GZIP_TEST_STRING_LENGTH=${#GZIP_TEST}
    if [[ $GZIP_TEST_STRING_LENGTH > 0 ]]; then
      echo $(date)" - [ERROR: GZip file appears to be damaged. Script stopping.]" & CHECK_PID=(`jobs -l | awk '{print $2}'`);
      wait ${CHECK_PID}
      exit 1; # Exit if fails.
    fi

    # Now that the file has been vetted, get the DATABASE_FILENAME & DATABASE_BASENAME
    DATABASE_FILENAME=$(basename "${DATABASE_FULLPATH}")
    DATABASE_BASENAME=${DATABASE_FILENAME%'.sql.gz'}

    ######################################################################################
    # If the 'USE_BACKUP_DATABASE' option is set, create a backup of previous MySQL database.
    ######################################################################################
    if ${USE_BACKUP_DATABASE} ; then

      # Dumps the primary database to a compressed database dump file.
      nice -n ${NICENESS} ${MYSQLDUMP_BINARY} --user=${DATABASE_USER} --password=${DATABASE_PASS} --single-transaction ${PRIMARY_DATABASE} | gzip > ${DATABASE_BACKUP_DIR}${BACKUP_DATABASE}${SUFFIX}'.sql.gz' & MYSQL_DUMP_PID=(`jobs -l | awk '{print $2}'`);
      wait ${MYSQL_DUMP_PID}

      # Decompresses the primary database archive into a new file for import purposes.
      nice -n ${NICENESS} gunzip -c ${DATABASE_BACKUP_DIR}${BACKUP_DATABASE}${SUFFIX}'.sql.gz' > ${DATABASE_BACKUP_DIR}${BACKUP_DATABASE}${SUFFIX}'.sql' & GZIP_PID=(`jobs -l | awk '{print $2}'`);
      wait ${GZIP_PID}

      # Takes the primary database dump & imports it into the backup database.
      nice -n ${NICENESS} ${MYSQL_BINARY} -u${DATABASE_USER} -p${DATABASE_PASS} ${BACKUP_DATABASE} < ${DATABASE_BACKUP_DIR}${BACKUP_DATABASE}${SUFFIX}'.sql' & MYSQL_RESTORE_PID=(`jobs -l | awk '{print $2}'`);
      wait ${MYSQL_RESTORE_PID}

      # Erases the uncompressed primary database dump.
      rm ${DATABASE_BACKUP_DIR}${BACKUP_DATABASE}${SUFFIX}'.sql' & RM_DUMP_PID=(`jobs -l | awk '{print $2}'`);
      wait ${RM_DUMP_PID}

    fi

    ######################################################################################
    # Import from the database export & create a fresh MySQL database.
    ######################################################################################
    # Decompresses the database archive into a new file for import purposes.
    nice -n ${NICENESS} gunzip -c ${DATABASE_FULLPATH} > ${TMP_DIR}${DATABASE_BASENAME}'.sql' & GZIP_PID=(`jobs -l | awk '{print $2}'`);
    wait ${GZIP_PID}

    # Takes the database dump & imports it into the primary database.
    if [ -f ${TMP_DIR}${DATABASE_BASENAME}'.sql' ]; then
      nice -n ${NICENESS} ${MYSQL_BINARY} -u${DATABASE_USER} -p${DATABASE_PASS} ${PRIMARY_DATABASE} < ${TMP_DIR}${DATABASE_BASENAME}'.sql' & DATABASE_IMPORT_PID=(`jobs -l | awk '{print $2}'`);
      wait ${DATABASE_IMPORT_PID}
    fi

    # Clean up any straggler files from the temp directory.
    find ${TMP_DIR} -maxdepth 1 -type f -mtime +${EXPIRATION} -name '*.sql.gz' -exec rm -f {} \;
    find ${TMP_DIR} -maxdepth 1 -type f -mtime +${EXPIRATION} -name '*.sql' -exec rm -f {} \;

  else
    echo "ERROR";
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