#!/bin/sh
date=`date +%Y%m%d`

/Applications/MAMP/Library/bin/mysqldump --add-drop-table --user=root --password=root dev_db | gzip > /Applications/MAMP/mysql_backup/dev_db-$date.sql.gz
