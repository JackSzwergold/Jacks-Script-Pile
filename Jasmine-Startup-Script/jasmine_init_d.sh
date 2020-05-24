#!/bin/bash
### BEGIN INIT INFO
# Provides:          jasmine
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop jasmine web server
### END INIT INFO

##########################################################################################
#
# Jasmine Init Script (jasmine_init_d.sh) (c) by Jack Szwergold
#
# Jasmine Init Script is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-11-20, js
# Version: 2014-11-20, js: creation
#          2014-11-20, js: development
#
##########################################################################################

# Set the user.
JASMINE_USER="[name of system user]"

# Set the networking stuff.
IFCONFIG_BIN="/sbin/ifconfig"
IFCONFIG_INTERFACE="eth1"
IP_ADDRESS=$($IFCONFIG_BIN $IFCONFIG_INTERFACE | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
PORT=8888

# Set the Jasmine stuff.
JASMINE_HOME="/full/path/to/web/app/using/jasmine"
JASMINE_NICKNAME="jasmine"

# Set the Bundle stuff.
RAKE_HOME='/usr/local/bin/rake'
RAKE_PARAMETERS="jasmine"

# Set the init.d specific stuff.
PID_FILENAME="/run/$JASMINE_NICKNAME.pid"
INITD_SCRIPTNAME="/etc/init.d/$JASMINE_NICKNAME"
# INDENT_SPACING=$(tput cols)
INDENT_SPACING=50

case "$1" in

start)

  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
  else
    PID_CHECK=$(pgrep -f $JASMINE_HOME)
  fi

  if [ ! -f "$PID_FILENAME" ] && [ -z "$PID_CHECK" ]; then
    printf "%-${INDENT_SPACING}s" "Starting $JASMINE_NICKNAME..."
    su "$JASMINE_USER" -c "cd $JASMINE_HOME && $RAKE_HOME $RAKE_PARAMETERS > /dev/null 2>&1 &";
    sleep 5
    PID=$(ps -ef | grep -v grep | grep "$RAKE_HOME $RAKE_PARAMETERS" | grep -v "bash" | awk '{print $2}')
    if [ -z "$PID" ]; then
      printf "Fail\n"
    else
      echo "$PID" > "$PID_FILENAME"
      if [ -f "$PID_FILENAME" ]; then
        printf "[ OK ]\n"
      fi
    fi
  else
    printf "$JASMINE_NICKNAME (pid $PID) already running.\n"
  fi

;;

status)

  printf "%-${INDENT_SPACING}s" "Checking $JASMINE_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ -z "$PID_CHECK" ]; then
      printf "Process not running but pidfile exists.\n"
    else
      printf "$JASMINE_NICKNAME (pid $PID) running.\n"
    fi
  else
    printf "$JASMINE_NICKNAME not running.\n"
  fi

;;

stop)

  printf "%-${INDENT_SPACING}s" "Stopping $JASMINE_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(pgrep -f $JASMINE_HOME)
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill "$PID"
    fi
    printf "[ OK ]\n"
    rm -f "$PID_FILENAME"
  else
    printf "$JASMINE_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

*)
  echo "Usage: $0 {status|start|stop}"
  exit 1
esac