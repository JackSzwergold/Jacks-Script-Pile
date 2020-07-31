#!/bin/bash -l

################################################################################
#
# Block IP addresses (block_ip_addresses.sh) (c) by Jack Szwergold
#
# Block IP addresses is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-04-30, js: Creation.
# Version: 2012-04-30, js: Tweaked & debugged.
#          2012-05-01, js: More cleanup.
#          2012-05-24, js: Added line-space between CATting of the TOR_80'.tmp' & TOR_9998'.tmp' files.
#          2015-10-28, js: Changing the action from DROP to REJECT.
#          2015-10-28, js: Switching to IPSet; IPTables method is an expensive process.
#          2015-10-29, js: Cleaning up this mess.
#          2015-11-03, js: Some restructuring.
#          2016-01-17, js: Major refactoring with arrays and loops.
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
config_file="./${lock_name}.cfg.sh";

# Checks if the base script directory exists.
if [ -f "${config_file}" ]; then
  source "${config_file}";
else
  echo $(date)" - [ERROR: Configuration file '${config_file}' not found. Script stopping.]" & task_pid=(`jobs -l | awk '{print $2}'`);
  wait ${task_pid};
  exit; # Exit if fails.
fi

################################################################################
# If IPSet is not on the system, bail out.
if [ -z "${IPSET_BIN}" ]; then
  exit;
fi

################################################################################
# Checks to make sure our working environment works.
################################################################################

if mkdir ${lock_directory} 2>/dev/null; then

  ##############################################################################
  # If the ${lock_directory} doesn't exist, then start working and store the ${task_pid_path}
  echo $$ > ${task_pid_path};

  ##############################################################################
  # Set a more specific base directory
  BASE_DIR="${BASE_DIR}${lock_name_full}_tmp/";

  ##############################################################################
  # And now force that new base directory into existence.
  mkdir -p "${BASE_DIR}";

  ##############################################################################
  #  _____ ___  ____
  # |_   _/ _ \|  _ \
  #   | || | | | |_) |
  #   | || |_| |  _ <
  #   |_| \___/|_| \_\
  #
  # RAW: Get the data from each TOR port.
  #
  ##############################################################################
  function tor_ips_process () {

    for TOR_PORT in "${TOR_PORT_ARRAY[@]}"
    do

      ##########################################################################
      # Init temp files.
      :> "${BASE_DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp";

      ##########################################################################
      # Get the list of exit nodes from TOR.
      curl -Lsf --connect-timeout "${CURL_TIMEOUT}" -o "${BASE_DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp" "${TOR_URL}${TOR_PORT}" >/dev/null 2>&1

      ##########################################################################
      # Combine the list of TOR exit nodes.
      awk 'FNR==1 { print "" } 1' "${BASE_DIR}${SET_TOR_IPS}_${TOR_PORT}.tmp" >> "${BASE_DIR}${SET_TOR_IPS}_RAW.tmp";

    done

    ############################################################################
    # CLEANED: Check if the raw list of TOR exit nodes exists and is not empty before doing anything else.
    if [[ -f "${BASE_DIR}${SET_TOR_IPS}_RAW.tmp" && -s "${BASE_DIR}${SET_TOR_IPS}_RAW.tmp" ]]; then

      ##########################################################################
      # Clean empty lines and comments out of the list of TOR exit nodes.
      grep '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' "${BASE_DIR}${SET_TOR_IPS}_RAW.tmp" | awk 'NF { print }' > "${BASE_DIR}${SET_TOR_IPS}_CLEANED.tmp"

    fi

    ############################################################################
    # SORTED: Check if the cleaned up list of TOR exit nodes exists and is not empty before doing anything else.
    if [[ -f "${BASE_DIR}${SET_TOR_IPS}_CLEANED.tmp" && -s "${BASE_DIR}${SET_TOR_IPS}_CLEANED.tmp" ]]; then

      ########################################################################
      # Sort the list of TOR exit nodes.
      cat "${BASE_DIR}${SET_TOR_IPS}_CLEANED.tmp" | sort | uniq > "${BASE_DIR}${SET_TOR_IPS}_SORTED.tmp";

      ##########################################################################
      # Init a new TOR_IPS file.
      :> "${BASE_DIR}rules.${SET_TOR_IPS}.ipset";

      ##########################################################################
      # If the IPSet file exists, do something.
      if [ -f "${BASE_DIR}rules.${SET_TOR_IPS}.ipset" ]; then

        ########################################################################
        # Use AWK to create the TOR IPSet config file.
        awk -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" 'NF {print "add TOR_IPS " $0 " timeout " IPSET_TIMEOUT}' "${BASE_DIR}${SET_TOR_IPS}_SORTED.tmp" > "${BASE_DIR}rules.${SET_TOR_IPS}.ipset";

      fi

    fi

  } # tor_ips_process

  ##############################################################################
  #   ____           ___ ____
  #  / ___| ___  ___|_ _|  _ \
  # | |  _ / _ \/ _ \| || |_) |
  # | |_| |  __/ (_) | ||  __/
  #  \____|\___|\___/___|_|
  #
  # Check if the GeoIP country CSV exists and is not empty before doing anything else.
  #
  ##############################################################################
  function geoip_country_process () {

    ############################################################################
    # If the GeoIP Country CSV file exits, then do something.
    if [[ -f "${GEOIP_COUNTRY_CSV}" && -s "${GEOIP_COUNTRY_CSV}" ]]; then

      ##########################################################################
      # Init a new SET_BANNED_RANGES file.
      :> "${BASE_DIR}rules.${SET_BANNED_RANGES}.ipset";

      ##########################################################################
      # If the IPSet file exists, do something.
      if [ -f "${BASE_DIR}rules.${SET_BANNED_RANGES}.ipset" ]; then

        ########################################################################
        # Roll through the array of country codes and use AWK to create the BANNED IPSet config file.
        for COUNTRY_CODE in "${COUNTRY_ARRAY[@]}"
        do
          awk -F "," -v COUNTRY_CODE="${COUNTRY_CODE}" -v IPSET_TABLE="${SET_BANNED_RANGES}" -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" '$5 ~ COUNTRY_CODE { gsub(/"/, "", $1); gsub(/"/, "", $2); print "add " IPSET_TABLE " " $1 "-" $2 " timeout " IPSET_TIMEOUT; }' "${GEOIP_COUNTRY_CSV}" >> "${BASE_DIR}rules.${SET_BANNED_RANGES}.ipset"
        done

      fi

    fi

  } # geoip_country_process

  ##############################################################################
  #     _                                        ___        ______
  #    / \   _ __ ___   __ _ _______  _ __      / \ \      / / ___|
  #   / _ \ | '_ ` _ \ / _` |_  / _ \| '_ \    / _ \ \ /\ / /\___ \
  #  / ___ \| | | | | | (_| |/ / (_) | | | |  / ___ \ V  V /  ___) |
  # /_/   \_\_| |_| |_|\__,_/___\___/|_| |_| /_/   \_\_/\_/  |____/
  #
  # Get the data from the AWS URL.
  #
  ##############################################################################
  function amazon_ips_process () {

    ############################################################################
    # If the URL exists, do something.
    if [ ! -z "${AMAZON_IP_RANGES_URL}" ]; then

      ##########################################################################
      # Init temp files.
      :> "${BASE_DIR}${SET_AMAZON_RANGES}.json";

      ##########################################################################
      # Get the list of AWS IP ranges.
      curl -Lsf --connect-timeout "${CURL_TIMEOUT}" -o "${BASE_DIR}${SET_AMAZON_RANGES}.json" "${AMAZON_IP_RANGES_URL}";

      ##########################################################################
      # Parse the raw JSON for the IP addreesses.
      jq -r '.prefixes[] | .ip_prefix' < "${BASE_DIR}${SET_AMAZON_RANGES}.json" | sort | uniq >  "${BASE_DIR}rules.${SET_AMAZON_RANGES}.tmp";

      ##########################################################################
      # Use AWK to create the IPSet config file.
      awk -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" 'NF {print "add AMAZON_RANGES " $0 " timeout " IPSET_TIMEOUT}' "${BASE_DIR}rules.${SET_AMAZON_RANGES}.tmp" > "${BASE_DIR}rules.${SET_AMAZON_RANGES}.ipset";

    fi

  } # amazon_ips_process

  ##############################################################################
  #  __  __ _                           __ _
  # |  \/  (_) ___ _ __ ___  ___  ___  / _| |_
  # | |\/| | |/ __| '__/ _ \/ __|/ _ \| |_| __|
  # | |  | | | (__| | | (_) \__ \ (_) |  _| |_
  # |_|  |_|_|\___|_|  \___/|___/\___/|_|  \__|
  #
  # Get the data from the Microsoft URL.
  #
  ##############################################################################
  function microsoft_ips_process () {

    ############################################################################
    # If the URL exists, do something.
    if [ ! -z "${MICROSOFT_IP_RANGES_URL}" ]; then

      ##########################################################################
      # Init temp files.
      :> "${BASE_DIR}${SET_MICROSOFT_RANGES}.xml";

      ##########################################################################
      # Now, of course Microsoft doesn’t make things simple. So the URL has to be parsed to actually get the *final* URL.
      MICROSOFT_IP_RANGES_URL_FINAL=$(curl -Lfs "${MICROSOFT_IP_RANGES_URL}" | grep -Eoi '<a [^>]+>' | grep -Eo 'href="[^\"]+"' | grep "download.microsoft.com/download/" | grep -m 1 -Eo '(http|https)://[^"]+');

      ##########################################################################
      # Get the list of AWS IP ranges.
      curl -Lsf --connect-timeout "${CURL_TIMEOUT}" -o "${BASE_DIR}${SET_MICROSOFT_RANGES}.xml" "${MICROSOFT_IP_RANGES_URL_FINAL}";

      ##########################################################################
      # Parse the raw JSON for the IP addreesses.
      grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' "${BASE_DIR}${SET_MICROSOFT_RANGES}.xml" | sort | uniq >  "${BASE_DIR}rules.${SET_MICROSOFT_RANGES}.tmp";

      ##########################################################################
      # Use AWK to create the IPSet config file.
      awk -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" 'NF {print "add MICROSOFT_RANGES " $0 " timeout " IPSET_TIMEOUT}' "${BASE_DIR}rules.${SET_MICROSOFT_RANGES}.tmp" > "${BASE_DIR}rules.${SET_MICROSOFT_RANGES}.ipset";

    fi

  } # microsoft_ips_process

  ##############################################################################
  #     _    ____  _   _
  #    / \  / ___|| \ | |
  #   / _ \ \___ \|  \| |
  #  / ___ \ ___) | |\  |
  # /_/   \_\____/|_| \_|
  #
  # Get the IP ranges based on ASN numbers.
  #
  ##############################################################################
  function asn_ips_process () {

    ############################################################################
    # Init temp files.
    :> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # Google (AS15169).
    whois -h whois.radb.net -- '-i origin AS15169' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq >> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # Facebook (AS32934).
    whois -h whois.radb.net -- '-i origin AS32934' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq >> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # Online SAS (AS12876).
    whois -h whois.radb.net -- '-i origin AS12876' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq >> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # DigitalOcean (AS14061).
    whois -h whois.radb.net -- '-i origin AS14061' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq >> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # Selectel (AS49505).
    whois -h whois.radb.net -- '-i origin AS49505' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq >> "${BASE_DIR}${SET_ASN_RANGES}.tmp";

    ############################################################################
    # Use AWK to create the IPSet config file.
    awk -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" 'NF {print "add GOOGLE_RANGES " $0 " timeout " IPSET_TIMEOUT}' "${BASE_DIR}${SET_ASN_RANGES}.tmp" > "${BASE_DIR}rules.${SET_ASN_RANGES}.ipset";

  } # asn_ips_process

  ##############################################################################
  # __        ___     _ _       _ _     _
  # \ \      / / |__ (_) |_ ___| (_)___| |_
  #  \ \ /\ / /| '_ \| | __/ _ \ | / __| __|
  #   \ V  V / | | | | | ||  __/ | \__ \ |_
  #    \_/\_/  |_| |_|_|\__\___|_|_|___/\__|
  #
  # Build a list of whitelisted IP addresses.
  #
  ##############################################################################
  function whitelist_ips_process () {

    ############################################################################
    # Init temp files.
    :> "${BASE_DIR}rules.${SET_WHITELIST_IPS}.tmp";

    ############################################################################
    # Add the main, public IP addresses to the temp file.
    if [ ! -z "${IP_ADDRESS}" ]; then
      echo ${IP_ADDRESS} >> "${BASE_DIR}rules.${SET_WHITELIST_IPS}.tmp";
    fi

    ############################################################################
    # Add the local, internal IP addresses to the temp file.
    if [ ! -z "${IP_ADDRESS_LOCAL}" ]; then
      echo ${IP_ADDRESS_LOCAL} >> "${BASE_DIR}rules.${SET_WHITELIST_IPS}.tmp";
    fi

    ############################################################################
    # Add the host for the Amazon IP ranges URL.
    dig +short $(echo ${AMAZON_IP_RANGES_URL} | awk -F[/:] '{print $4}') | grep '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' >> "${BASE_DIR}rules.${SET_WHITELIST_IPS}.tmp";

    ############################################################################
    # Use AWK to create the IPSet config file.
    awk -v IPSET_TIMEOUT="${IPSET_TIMEOUT}" 'NF {print "add WHITELIST_IPS " $0 " timeout " IPSET_TIMEOUT}' "${BASE_DIR}rules.${SET_WHITELIST_IPS}.tmp" > "${BASE_DIR}rules.${SET_WHITELIST_IPS}.ipset";

  } # whitelist_ips_process

  ##############################################################################
  #  _                    _   ___ ____  ____       _
  # | |    ___   __ _  __| | |_ _|  _ \/ ___|  ___| |_ ___
  # | |   / _ \ / _` |/ _` |  | || |_) \___ \ / _ \ __/ __|
  # | |__| (_) | (_| | (_| |  | ||  __/ ___) |  __/ |_\__ \
  # |_____\___/ \__,_|\__,_| |___|_|   |____/ \___|\__|___/
  #
  # Roll through each set name, and set the values into the IPSet stuff.
  #
  ##############################################################################
  function load_ipset_process () {

    ############################################################################
    # Roll through the setname array.
    for SETNAME in "${SETNAME_ARRAY[@]}"
    do

      ##########################################################################
      # If the IPSet file exists, do something.
      if [[ -f "${BASE_DIR}rules.${SETNAME}.ipset" && -s "${BASE_DIR}rules.${SETNAME}.ipset" ]]; then

        ########################################################################
        # If the set doesn't exist create it.
        ${IPSET_BIN} create -q ${SETNAME} hash:net timeout ${IPSET_TIMEOUT};

        ########################################################################
        # Flush the currently set values from the TOR chain and restore the chain with the new values.
        # echo "${IPSET_BIN} restore -! -q < ${BASE_DIR}rules.${SETNAME}.ipset"
        ${IPSET_BIN} restore -! -q < "${BASE_DIR}rules.${SETNAME}.ipset";

      fi

      ##########################################################################
      # Delete the files when things are done. Or not?
      # rm -f /tmp/*.{json,xml,tmp,ipset}

    done

  } # load_ipset_process

  ##############################################################################
  # Now run each of these functions to get things running.
  tor_ips_process;
  geoip_country_process;
  amazon_ips_process;
  microsoft_ips_process;
  asn_ips_process;
  whitelist_ips_process;
  load_ipset_process;

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
# And that's all there is!
exit
