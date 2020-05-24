#!/bin/bash
### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop unicorn web server
### END INIT INFO

##########################################################################################
#
# Unicorn Init Script (unicorn_init_d.sh) (c) by Jack Szwergold
#
# Unicorn Init Script is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-11-18, js
# Version: 2014-11-18, js: creation
#          2014-11-18, js: development
#          2014-12-11, js: adding RVM setup support
#          2014-12-27, js: adding more control options
#
##########################################################################################

# Set the user.
UNICORN_USER="[name of system user]"

# Set the networking stuff.
IFCONFIG_BIN="/sbin/ifconfig"
IFCONFIG_INTERFACE="eth1"
IP_ADDRESS=$($IFCONFIG_BIN $IFCONFIG_INTERFACE | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
PORT=3000

# Set the Unicorn stuff.
UNICORN_HOME="/full/path/to/web/app/using/unicorn"
UNICORN_NICKNAME="unicorn"

# Set the Bundle stuff.
# BUNDLE_HOME='/usr/local/bin/bundle'
BUNDLE_HOME='/home/username/.rvm/wrappers/ruby-2.1.1@something/bundle'
BUNDLE_PARAMETERS="exec unicorn_rails -D -c ./config/unicorn/localhost.rb"

# Set the init.d specific stuff.
PID_FILENAME="/run/$UNICORN_NICKNAME.pid"
INITD_SCRIPTNAME="/etc/init.d/$UNICORN_NICKNAME"
# INDENT_SPACING=$(tput cols)
INDENT_SPACING=50

case "$1" in

status)

  printf "%-${INDENT_SPACING}s" "Checking $UNICORN_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ -z "$PID_CHECK" ]; then
      printf "Process not running but pidfile exists.\n"
    else
      printf "$UNICORN_NICKNAME (pid $PID) running.\n"
    fi
  else
    printf "$UNICORN_NICKNAME not running.\n"
  fi

;;

start)

  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
  else
    PID_CHECK=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
  fi

  if [ ! -f "$PID_FILENAME" ] && [ -z "$PID_CHECK" ]; then
    printf "%-${INDENT_SPACING}s" "Starting $UNICORN_NICKNAME..."
    su "$UNICORN_USER" -c "cd $UNICORN_HOME && $BUNDLE_HOME $BUNDLE_PARAMETERS > /dev/null 2>&1"
    PID=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
    if [ -z "$PID" ]; then
      printf "Fail\n"
    else
      echo "$PID" > "$PID_FILENAME"
      if [ -f "$PID_FILENAME" ]; then
        printf "[ OK ]\n"
      fi
    fi
  else
    printf "$UNICORN_NICKNAME (pid $PID) already running.\n"
  fi

;;

stop)

  printf "%-${INDENT_SPACING}s" "Stopping $UNICORN_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill -QUIT "$PID"
    fi
    printf "[ OK ]\n"
    rm -f "$PID_FILENAME"
  else
    printf "$UNICORN_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

force-stop)

  printf "%-${INDENT_SPACING}s" "Force stopping $UNICORN_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill -TERM "$PID"
    fi
    printf "[ OK ]\n"
    rm -f "$PID_FILENAME"
  else
    printf "$UNICORN_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

rotate)

  printf "%-${INDENT_SPACING}s" "Log rotate $UNICORN_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill -USR1 "$PID"
    fi
    printf "[ OK ]\n"
  else
    printf "$UNICORN_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

restart|reload)

  printf "%-${INDENT_SPACING}s" "Reload $UNICORN_NICKNAME..."
  if [ -f "$PID_FILENAME" ]; then
    PID=`cat $PID_FILENAME`
    # PID_CHECK=$(ps aux | grep '[u]nicorn_rails master' | awk '{print $2}')
    PID_CHECK=`ps axf | grep ${PID} | grep -v grep`
    if [ ! -z "$PID_CHECK" ]; then
      kill -HUP "$PID"
    fi
    printf "[ OK ]\n"
  else
    printf "$UNICORN_NICKNAME pidfile ($PID_FILENAME) not found.\n"
  fi

;;

*)
  echo "Usage: $0 {status|start|stop|force-stop|rotate|restart|reload}"
  exit 1
esac