#!/bin/bash

##########################################################################################
#
# LDAP Account Check (ldap_account_check.sh) (c) by Jack Szwergold
#
# LDAP Account Check is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>. 
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2014-07-03, js
# Version: 2014-07-03, js: creation
#          2014-10-31, js: development
#
##########################################################################################

# Set the lock file & directory to prevent the script running on top of each other.
LOCK_NAME='LDAP_SEARCH_PROCESS'
LOCK_DIR='/tmp/'"${LOCK_NAME}"'.lock'
PID_FILE="${LOCK_DIR}"'/'"${LOCK_NAME}"'.pid'

##########################################################################################
# Load the configuration file.
##########################################################################################

# Set the config file.
CONFIG_FILE="./ldap_account_check.cfg.sh"

# Checks if the base script directory exists.
if [ -f "${CONFIG_FILE}" ]; then
  source "${CONFIG_FILE}"
else
  echo $(date)" - [ERROR: Configuration file '${CONFIG_FILE}' not found. Script stopping.]" & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
fi

##########################################################################################
# Here is where the magic begins!
##########################################################################################

# Checks if 'ldapsearch' exists.
hash 'ldapsearch' 2>/dev/null || {
  echo >&2 $(date)" - ['ldapsearch' not found. Script stopping.]" >> ${ANNEX_IMAGE_LOGFILE} & LOGGER_PID=(`jobs -l | awk '{print $2}'`);
  wait ${LOGGER_PID}
  exit 1;
}

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # Output the results.
  echo "LDAP_ACCOUNT_NAME","CN_NAME_VALUE","MAIL_VALUE","DEPARTMENT_VALUE","EXPIRATION_STATUS","EXPIRATION_DATE","EXPIRATION_TIME","ACCOUNTEXPIRES_UNIX_TIMESTAMP","NOW_TIMESTAMP","DATE_DELTA";

  ######################################################################################
  # Loop through the contents of the LDAP_ACCOUNTS_FILE
  ######################################################################################
  while read LDAP_ACCOUNT_NAME; do

    # Build & fetch the LDAP query.
    LDAPQUERY='sAMAccountName='${LDAP_ACCOUNT_NAME}
    LDAP_RESPONSE=$(nice -n ${NICENESS} ldapsearch -x -h "${LDAPHOST}" -D "${BINDDN}" -b "${SEARCHBASE}" -w "${PASSWORD}" -L "${LDAPQUERY}");
    sleep ${SLEEPINESS};

    # Parse the LDAP response.
    MAILNICKNAME="";
    MAILNICKNAME=$(echo "${LDAP_RESPONSE}" | grep -w "mailNickname");
    MAILNICKNAME_ARRAY=(${MAILNICKNAME//:/ });
    MAILNICKNAME_VALUE="${MAILNICKNAME_ARRAY[1]}";

    CN_NAME="";
    CN_NAME=$(echo "${LDAP_RESPONSE}" | grep -w "cn");
    CN_NAME_ARRAY=(${CN_NAME//:/ });
    CN_NAME_VALUE=$(echo ${CN_NAME_ARRAY[1]} ${CN_NAME_ARRAY[2]});

    DEPARTMENT="";
    DEPARTMENT=$(echo "${LDAP_RESPONSE}" | grep -w "department");
    DEPARTMENT_ARRAY=(${DEPARTMENT//:/ });
    DEPARTMENT_VALUE=$(echo ${DEPARTMENT_ARRAY[1]} ${DEPARTMENT_ARRAY[2]} ${DEPARTMENT_ARRAY[3]} ${DEPARTMENT_ARRAY[4]});

    AAMACCOUNTNAME="";
    AAMACCOUNTNAME=$(echo "${LDAP_RESPONSE}" | grep -w "aAMAccountName");
    AAMACCOUNTNAME_ARRAY=(${AAMACCOUNTNAME//:/ });
    AAMACCOUNTNAME_VALUE="${AAMACCOUNTNAME_ARRAY[1]}";

    ACCOUNTEXPIRES="";
    ACCOUNTEXPIRES=$(echo "${LDAP_RESPONSE}" | grep -w "accountExpires");
    ACCOUNTEXPIRES_ARRAY=(${ACCOUNTEXPIRES//:/ });
    ACCOUNTEXPIRES_TIMESTAMP="${ACCOUNTEXPIRES_ARRAY[1]}";

    MAIL="";
    MAIL=$(echo "${LDAP_RESPONSE}" | grep -w "mail");
    MAIL_ARRAY=(${MAIL//:/ });
    MAIL_VALUE="${MAIL_ARRAY[1]}";

    DN_OU_DISABLED="";
    DISTINGUISHED_NAME="";
    DISTINGUISHED_NAME=$(echo "${LDAP_RESPONSE}" | grep -w "dn");
    DN_OU_DISABLED=$(echo "${DISTINGUISHED_NAME}" | grep -w "OU=Disabled Accounts");

    # Set the timestamp for 'now'.
    NOW_TIMESTAMP=$(date +%s);

    # Check the expiration date.
    ACCOUNTEXPIRES_UNIX_TIMESTAMP="";
    EXPIRATION_STATUS="UNKNOWN"
    EXPIRATION_DATE="";
    EXPIRATION_TIME="";

    # If there is a valid 18 digit Active Directory timestamp, process it.
    if [[ ${#ACCOUNTEXPIRES_TIMESTAMP} -eq 18 ]]; then
      # Convert Active Directory timestamp to a UNIX timestamp.
      # date +%s; # Today
      ACCOUNTEXPIRES_UNIX_TIMESTAMP=$(((($ACCOUNTEXPIRES_TIMESTAMP/10000000)-11644473600)));
      if [[ "$OSTYPE" =~ ^darwin ]]; then
        EXPIRATION_DATEFULL=$(perl -le "print scalar localtime ${ACCOUNTEXPIRES_UNIX_TIMESTAMP}"); # Works in OS X
      else
        EXPIRATION_DATEFULL=$(date -d @${ACCOUNTEXPIRES_UNIX_TIMESTAMP}); # Works in Linux
      fi

      # Set the 'EXPIRATION_DATE' & 'EXPIRATION_TIME'
      if [ -n "${EXPIRATION_DATEFULL}" ]; then
        EXPIRATION_STATUS="ACTIVE";
        EXPIRATION_ARRAY=(${EXPIRATION_DATEFULL// / });
        EXPIRATION_DATE="${EXPIRATION_ARRAY[1]} ${EXPIRATION_ARRAY[2]}, ${EXPIRATION_ARRAY[4]}";
        EXPIRATION_TIME="${EXPIRATION_ARRAY[3]}";
      fi

    # If the accountExpires value matches the two crazy Active Directory values Microsoft has defined, it's active.
    elif [[ "${ACCOUNTEXPIRES_TIMESTAMP}" -eq "${LDAP_NO_EXPIRATION_MIN}" || "${ACCOUNTEXPIRES_TIMESTAMP}" -eq "${LDAP_NO_EXPIRATION_MAX}" ]]; then
      EXPIRATION_STATUS="ACTIVE";
      EXPIRATION_DATE="";
      EXPIRATION_TIME="";
    fi

    # Check if the account has expired by comparing
    if [[ -n ${ACCOUNTEXPIRES_UNIX_TIMESTAMP} && $((ACCOUNTEXPIRES_UNIX_TIMESTAMP-NOW_TIMESTAMP)) -le 0 ]]; then
      EXPIRATION_STATUS="EXPIRED";
    else
      EXPIRATION_STATUS="ACTIVE";
    fi

    DATE_DELTA="";
    if [ -n "${ACCOUNTEXPIRES_UNIX_TIMESTAMP}" ]; then
      DATE_DELTA=$((ACCOUNTEXPIRES_UNIX_TIMESTAMP-NOW_TIMESTAMP));
    fi

    # Check if the account has an e-mail address.
    if [ -z "${MAIL_VALUE}" ]; then
      EXPIRATION_STATUS="NO_EMAIL"
    fi

    # Check if the account is set explicitly as disabled as an organizational unit.
    if [ ! -z "${DN_OU_DISABLED}" ]; then
      EXPIRATION_STATUS="DISABLED"
    fi

    # Output the results.
    echo "\"${LDAP_ACCOUNT_NAME}\"","\"${CN_NAME_VALUE}\"","\"${MAIL_VALUE}\"","\"${DEPARTMENT_VALUE}\"","\"${EXPIRATION_STATUS}\"","\"${EXPIRATION_DATE}\"","\"${EXPIRATION_TIME}\"","\"${ACCOUNTEXPIRES_UNIX_TIMESTAMP}\"","\"${NOW_TIMESTAMP}\"","\"${DATE_DELTA}\"";

  done < "${LDAP_ACCOUNTS_FILE}"

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