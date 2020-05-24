#!/bin/bash
### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop resque
### END INIT INFO

##########################################################################################
#
# Resque Init Script (resque_init_d.sh) (c) by Jack Szwergold
#
# Report Disk Usage is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-12-25, js
# Version: 2014-12-25, js: creation
#          2014-12-25, js: development
#
##########################################################################################

# Set the user.
RESQUE_USER="[name of system user]"

# Set the Unicorn stuff.
RESQUE_HOME="/full/path/to/web/app/using/resque"
RESQUE_NICKNAME="resque"

# Set the init.d specific stuff.
PID_FILENAME="/run/$RESQUE_NICKNAME.pid"
INITD_SCRIPTNAME="/etc/init.d/$RESQUE_NICKNAME"
# INDENT_SPACING=$(tput cols)
INDENT_SPACING=50

# Set the Bundle stuff.
# BUNDLE_HOME='/usr/local/bin/bundle'
BUNDLE_HOME='/home/username/.rvm/wrappers/ruby-2.1.5@something/bundle'
BUNDLE_ENVIRONMENT="BACKGROUND=yes QUEUE=* PIDFILE=$PID_FILENAME"
BUNDLE_PARAMETERS="exec rake environment resque:work"

case "$1" in

start)

  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
  else
    PID_CHECK=$(ps aux | grep '[r]esque-' | awk '{print $2}')
  fi

  if [ ! -f "$PID_FILENAME" ] && [ -z "$PID_CHECK" ]; then
    printf "%-${INDENT_SPACING}s" "Starting $RESQUE_NICKNAME..."
    su "$RESQUE_USER" -c "cd $RESQUE_HOME && $BUNDLE_ENVIRONMENT $BUNDLE_HOME $BUNDLE_PARAMETERS > /dev/null 2>&1"
    sleep 5
    PID=$(ps aux | grep '[r]esque-' | awk '{print $2}')
    if [ -z "$PID" ]; then
      printf "Fail\n"
    else
      echo "$PID" > "$PID_FILENAME"
      if [ -f "$PID_FILENAME" ]; then
        printf "[ OK ]\n"
      fi
    fi
  else
    printf "$RESQUE_NICKNAME (pid $PID) already running.\n"
  fi

;;

status)

  printf "%-${INDENT_SPACING}s" "Checking $RESQUE_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ -z "$PID_CHECK" ]; then
      printf "Process not running but pidfile exists.\n"
    else
      printf "$RESQUE_NICKNAME (pid $PID) running.\n"
    fi
  else
    printf "$RESQUE_NICKNAME not running.\n"
  fi

;;

stop)

  printf "%-${INDENT_SPACING}s" "Stopping $RESQUE_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(ps aux | grep '[r]esque-' | awk '{print $2}')
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill "$PID"
    fi
    printf "[ OK ]\n"
    rm -f "$PID_FILENAME"
  else
    printf "$RESQUE_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

*)
  echo "Usage: $0 {status|start|stop}"
  exit 1
esac
