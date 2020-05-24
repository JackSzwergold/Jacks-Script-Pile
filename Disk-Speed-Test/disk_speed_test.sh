#!/bin/sh

##########################################################################################
#
# Disk Speed Test (disk_speed_test.sh) (c) by Jack Szwergold
#
# Disk Speed Test is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-07-03, js
# Version: 2012-07-03, js: creation
#          2012-07-03, js: development
#
##########################################################################################

# Default that sets count to 3 and the output to '/tmp/speed_test_file' : ./disk_speed_test.sh
# Usage: ./disk_speed_test.sh [test count] [full path for test file]

LOCK_NAME="DISK_SPEED_TEST";
LOCK_DIR=/tmp/${LOCK_NAME}.lock;
PID_FILE=${LOCK_DIR}/${LOCK_NAME}.pid;
WRITE_INPUT_FILE="/dev/zero";

TEST_COUNT=$1;
: ${TEST_COUNT:=3};

WRITE_OUTPUT_FILE=$2;
: ${WRITE_OUTPUT_FILE:="/tmp/speed_test_file"};


if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE};

  # Disk write test.
  echo '\n';
  echo '*** Disk Write Speed Test ***';
  for (( write_count=1; write_count<=${TEST_COUNT}; write_count++ ))
  do
    dd if=${WRITE_INPUT_FILE} of=${WRITE_OUTPUT_FILE} bs=512 count=4194304 >/dev/null & WRITE_PID=`jobs -l | awk '{print $2}'`;
    wait ${WRITE_PID};
  done
  echo '\n';

  # Disk read test.
  echo '\n';
  echo '*** Disk Read Speed Test ***';
  for (( read_count=1; read_count<=${TEST_COUNT}; read_count++ ))
  do
    dd of=${WRITE_INPUT_FILE} if=${WRITE_OUTPUT_FILE} bs=512 >/dev/null & READ_PID=`jobs -l | awk '{print $2}'`;
    wait ${READ_PID};
  done
  echo '\n';

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
    rm -rf ${LOCK_DIR};
    exit
  fi
fi
