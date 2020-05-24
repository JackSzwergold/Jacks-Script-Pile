#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the unique server name.
SERVER_NAME="${HOSTNAME}";

# Set the suffix using date & time info.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
SUFFIX='-'${DATE}'-'${TIME};

# Set the backup array.
BACKUP_ARRAY=();
BACKUP_ARRAY[0]='content';

# Set the source & backup directories.
SOURCE_DIRECTORY='/var/www/';
BACKUP_DIRECTORY='/opt/server_backups/'${SERVER_NAME}'_webapps/';

# Set the AWStats directories.
AWSTATS_SOURCE_DIRECTORY='/usr/share/';
AWSTATS_APP_DIRECTORY='awstats-7.3';

# Set the Munin LIB directories.
MUNIN_LIB_DIRECTORY='/var/lib/';
MUNIN_LIB_APP_DIRECTORY='munin';

# Set the Munin CACHE directories.
MUNIN_CACHE_DIRECTORY='/var/cache/munin/';
MUNIN_CACHE_APP_DIRECTORY='www';

# Set the expiration.
EXPIRATION=1