#!/bin/bash -l

##########################################################################################
#
# GeoIP Updates (geoip_updates.sh) (c) by Jack Szwergold
#
# GeoIP Updates is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-06-15, js
# Version: 2012-06-15, js: creation
#          2012-06-15, js: development
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

  ##############################################################################
  # Get the GeoIP country data.
  wget -N -q ${GEOIP_COUNTRY_URL} -O ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz >/dev/null & GEOIP_COUNTRY_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_COUNTRY_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoLiteCountry.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    mv -f ${GEOIP_DIRECTORY}GeoLiteCountry.dat ${GEOIP_DIRECTORY}GeoIP.dat >/dev/null & MOVE_GEOIP_COUNTRY_PID=`jobs -l | awk '{print $2}'`;
    wait ${MOVE_GEOIP_COUNTRY_PID};
  fi

  ##############################################################################
  # Get the GeoIP city data.
  wget -N -q ${GEOIP_CITY_URL} -O ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz >/dev/null & GEOIP_CITY_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_CITY_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoLiteCity.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    mv -f ${GEOIP_DIRECTORY}GeoLiteCity.dat ${GEOIP_DIRECTORY}GeoIPCity.dat >/dev/null & MOVE_GEOIP_CITY_PID=`jobs -l | awk '{print $2}'`;
    wait ${MOVE_GEOIP_CITY_PID};
  fi

  ##############################################################################
  # Get the GeoIP ASNum (Autonomous System Numbers) data.
  wget -N -q ${GEOIP_ASNUM_URL} -O ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz >/dev/null & GEOIP_ASNUM_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_ASNUM_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz ]; then
    gzip -df ${GEOIP_DIRECTORY}GeoIPASNum.dat.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};
  fi

  ##############################################################################
  # Get the GeoIP Country CSV data.
  wget -N -q ${GEOIP_COUNTRY_CSV_URL} -O ${GEOIP_DIRECTORY}GeoIP-legacy.csv.gz >/dev/null & GEOIP_COUNTRY_CSV_PID=`jobs -l | awk '{print $2}'`;
  wait ${GEOIP_COUNTRY_CSV_PID};

  if [ -s ${GEOIP_DIRECTORY}GeoIP-legacy.csv.gz ]; then
    gzip -df ${GEOIP_DIRECTORY} ${GEOIP_DIRECTORY}GeoIP-legacy.csv.gz >/dev/null & GZIP_PID=`jobs -l | awk '{print $2}'`;
    wait ${GZIP_PID};

    mv -f ${GEOIP_DIRECTORY}GeoIP-legacy.csv ${GEOIP_DIRECTORY}GeoIPCountryWhois.csv >/dev/null & MOVE_GEOIP_COUNTRY_PID=`jobs -l | awk '{print $2}'`;
    wait ${MOVE_GEOIP_COUNTRY_PID};

    rm -f ${GEOIP_DIRECTORY}GeoIP-legacy.csv.gz
  fi

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

