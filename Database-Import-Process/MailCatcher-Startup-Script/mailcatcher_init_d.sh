#!/bin/bash
### BEGIN INIT INFO
# Provides:          mailcatcher
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop mailcatcher web server
### END INIT INFO

##########################################################################################
#
# MailCatcher Init Script (mailcatcher_init_d.sh) (c) by Jack Szwergold
#
# MailCatcher Init Script is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-11-19, js
# Version: 2014-11-19, js: creation
#          2014-11-19, js: development
#          2014-12-11, js: adding RVM setup support
#
##########################################################################################

# Set the user.
MAILCATCHER_USER="[name of system user]"

# Set the networking stuff.
IFCONFIG_BIN="/sbin/ifconfig"
IFCONFIG_INTERFACE="eth1"
HTTP_IP_ADDRESS=$($IFCONFIG_BIN $IFCONFIG_INTERFACE | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
HTTP_PORT=1080

# Set the MailCatcher stuff.
# MAILCATCHER_BINARY_HOME='/usr/local/bin/mailcatcher'
# MAILCATCHER_WRAPPER_HOME=$MAILCATCHER_BINARY_HOME
MAILCATCHER_BINARY_HOME='/home/[username]/.rvm/gems/ruby-2.1.5/bin/mailcatcher'
MAILCATCHER_WRAPPER_HOME='/home/[username]/.rvm/gems/ruby-2.1.5/wrappers/mailcatcher'
MAILCATCHER_PARAMETERS="--http-ip=$HTTP_IP_ADDRESS --http-port=$HTTP_PORT"
MAILCATCHER_NICKNAME="mailcatcher"

# Set the init.d specific stuff.
PID_FILENAME="/run/$MAILCATCHER_NICKNAME.pid"
INITD_SCRIPTNAME="/etc/init.d/$MAILCATCHER_NICKNAME"
# INDENT_SPACING=$(tput cols)
INDENT_SPACING=50

case "$1" in

start)

  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
  else
    PID_CHECK=$(pgrep -f $MAILCATCHER_BINARY_HOME)
  fi

  if [ ! -f "$PID_FILENAME" ] && [ -z "$PID_CHECK" ]; then
    printf "%-${INDENT_SPACING}s" "Starting $MAILCATCHER_NICKNAME..."
    su "$MAILCATCHER_USER" -c "$MAILCATCHER_WRAPPER_HOME $MAILCATCHER_PARAMETERS > /dev/null 2>&1"
    sleep 5
    PID=$(pgrep -f $MAILCATCHER_BINARY_HOME)
    if [ -z "$PID" ]; then
      printf "Fail\n"
    else
      echo "$PID" > "$PID_FILENAME"
      if [ -f "$PID_FILENAME" ]; then
        printf "[ OK ]\n"
      fi
    fi
  else
    printf "$MAILCATCHER_NICKNAME (pid $PID) already running.\n"
  fi

;;

status)

  printf "%-${INDENT_SPACING}s" "Checking $MAILCATCHER_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ -z "$PID_CHECK" ]; then
      printf "Process not running but pidfile exists.\n"
    else
      printf "$MAILCATCHER_NICKNAME (pid $PID) running.\n"
    fi
  else
    printf "$MAILCATCHER_NICKNAME not running.\n"
  fi

;;

stop)

  printf "%-${INDENT_SPACING}s" "Stopping $MAILCATCHER_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill "$PID"
    fi
    printf "[ OK ]\n"
    rm -f "$PID_FILENAME"
  else
    printf "$MAILCATCHER_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

*)
  echo "Usage: $0 {status|start|stop}"
  exit 1
esac