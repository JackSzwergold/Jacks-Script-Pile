#!/bin/bash

##########################################################################################
#
# Purge Mod Security IP Data (purge_mod_security_ip_data.sh) (c) by Jack Szwergold
#
# Purge Mod Security IP Data is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-10-09, js
# Version: 2014-10-09, js: creation
#          2014-10-09, js: development
#
##########################################################################################

LOCK_NAME="PURGE_MOD_SECURITY_IP_DATA"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

MOD_SECURITY_IP_DIR="/tmp/ip.dir"
MOD_SECURITY_IP_PAG="/tmp/ip.pag"

APACHE_RESTART="/etc/init.d/apache2 graceful"

##########################################################################################
# Here is where the magic begins!
##########################################################################################

# Main process.
if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Delete the 'ip.dir' file.
  if [ -f ${MOD_SECURITY_IP_DIR} ]; then
    rm -f ${MOD_SECURITY_IP_DIR}
  fi

  # Delete the 'ip.pag' file.
  if [ -f ${MOD_SECURITY_IP_PAG} ]; then
    rm -f ${MOD_SECURITY_IP_PAG}
  fi

  # Restart Apache
  ${APACHE_RESTART}

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

