#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the unique server name.
SERVER_NAME="${HOSTNAME}";

# Set basic variables.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
BACKUP_DIRECTORY='/opt/server_backups/'${SERVER_NAME}'_configs/';
BACKUP_SUBDIRECTORY=${SERVER_NAME}'_configs-'${DATE}'/';
PREFIX=${SERVER_NAME}'-';
# SUFFIX='-'${DATE}'-'${TIME};
SUFFIX='-'${DATE};
EXPIRATION=7

# Location of config files.
ETC_DIRECTORY='/etc/';
APACHE_CONFIG_NAME='apache2';
APACHE_CONFIG_SUBDIRECTORY='apache2/';
PHP_CONFIG='/etc/php5/apache2/php.ini';
MYSQL_CONFIG='/etc/mysql/my.cnf';
PROFTPD_CONFIG='/etc/proftpd/proftpd.conf';
SSH_CONFIG='/etc/ssh/ssh_config';
SSHD_CONFIG='/etc/ssh/sshd_config';
MOD_SECURITY_CONFIG_NAME='modsecurity';
MOD_SECURITY_CONFIG_SUBDIRECTORY='modsecurity/';

