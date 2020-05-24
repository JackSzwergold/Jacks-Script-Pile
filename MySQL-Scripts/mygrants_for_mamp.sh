# Based on this tip from Server Fault:
# http://serverfault.com/a/13050/100013
#
# Usage
# ./MAMP_mygrants.sh --host=localhost --user=[user_name] --password=[the_password]

/Applications/MAMP/Library/bin/mysql -B -N $@ -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR ''', user, '''@''', host, ''';'
    ) AS query FROM mysql.user" | \
  /Applications/MAMP/Library/bin/mysql $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
