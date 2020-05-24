#!/bin/bash

##########################################################################################
#
# DShield Blocklist2CSV (dshield_blocklist2csv.sh) (c) by Jack Szwergold
#
# DShield Blocklist2CSV is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2016-01-15, js: Creation.
# Version: 2016-01-15, js: Tweaked & debugged.
#          2016-01-15, js: Development.
#
##########################################################################################

LOCK_NAME="DSHIELD_BLOCKLIST2CSV"
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

TMP_DIR="/tmp/"
BLOCKLIST_URL="https://isc.sans.edu/ipsascii.html?limit=1000"
BLOCKLIST_TMP=${TMP_DIR}"ipsascii.tmp"
BLOCKLIST_CSV=${TMP_DIR}"ipsascii.csv"

# Setting a simple lock check to ensure this script only runs when any earlier launch has ended.
if mkdir ${LOCK_DIR} 2>/dev/null; then

  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Get the list of exit nodes from TOR.
  curl -L --connect-timeout 30 -o ${BLOCKLIST_TMP} ${BLOCKLIST_URL} >/dev/null 2>&1

  # Check if the BLOCKLIST_TMP actually exists—and is not empty—before doing anything else.
  if [ -f ${BLOCKLIST_TMP} ]; then
    if [ -s ${BLOCKLIST_TMP} ]; then

      # Init a new BLOCKLIST_CSV file.
      :> ${BLOCKLIST_CSV}

      # Set the CSV header.
      echo "IP Address,Targets,Reports,First Seen,Last Seen" >> ${BLOCKLIST_CSV};

      # Process the BLOCKLIST_TMP file and convert it into BLOCKLIST_CSV format.
      cat ${BLOCKLIST_TMP} | sed -e '/^[[:blank:]]*#/d;s/#.*//' -e 's/[[:space:]]\{1,\}/,/g' -e 's/\.0\{1,2\}/\./g' -e 's/^0\{1,2\}//' >> ${BLOCKLIST_CSV};

    fi
  fi

  # Remove the BLOCKLIST_TMP file.
  rm -f ${BLOCKLIST_TMP}

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
