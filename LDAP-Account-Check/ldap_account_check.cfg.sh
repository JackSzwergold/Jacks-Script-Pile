#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# How nice should the script be to other processes: 0-19
NICENESS=19

# Sets a pause for the time between process loops.
SLEEPINESS=0.125

# Set the suffix using date & time info.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
SUFFIX="-"${DATE}"-"${TIME};

# Set the general LDAP info.
LDAPHOST='domain_controller.someplace.local';
BINDDN='ldapuser@someplace.local';
PASSWORD='password_for_ldapuser';
SEARCHBASE='DC=something,DC=someplace,DC=local';
LDAP_NO_EXPIRATION_MIN='0';
# LDAP_NO_EXPIRATION_MAX='2147483647'; # 32-bit
LDAP_NO_EXPIRATION_MAX='9223372036854775807'; # 64-bit

# Set the general LDAP info.
LDAP_ACCOUNTS_FILE="ldap_account_check.txt";
