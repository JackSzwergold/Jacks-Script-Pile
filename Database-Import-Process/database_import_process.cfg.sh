#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# How nice should the script be to other processes: 0-19
NICENESS=19

# Set the suffix using date & time info.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
SUFFIX="-"${DATE}"-"${TIME};

# Set the explicit locations of the MySQL related binaries.
MYSQL_BINARY='/Applications/MAMP/Library/bin/mysql'
MYSQLDUMP_BINARY='/Applications/MAMP/Library/bin/mysqldump'
 
DATABASE_USER="root"
DATABASE_PASS="root"
PRIMARY_DATABASE="db_to_import"
BACKUP_DATABASE="db_to_backup"

DATABASE_DUMP_DIR="/Applications/MAMP/mysql_dump/"
DATABASE_FILE_SEARCH_PATTERN="db_to_import"
DATABASE_FILE_EXTENSION=".sql.gz"

TMP_DIR="/Applications/MAMP/db_workspace/"
DATABASE_BACKUP_DIR="/Applications/MAMP/mysql_dump/"

# This is where the magic happens: ls -lrt . | awk '/'.sh'/ { f=$NF }; END { print f }'
MOST_RECENT_DATABASE=$(ls -lrt ${DATABASE_DUMP_DIR} | awk '/'${DATABASE_FILE_SEARCH_PATTERN}'/ { f=$NF }; END { print f }');

USE_BACKUP_DATABASE=true
EXPIRATION=1
