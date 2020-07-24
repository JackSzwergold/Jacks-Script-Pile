#!/bin/bash -l

# Some tests on using MaxMind’s database to get Facebok ASN related IP ranges.

grep -w '32934' 'GeoLite2-ASN-Blocks-IPv4.csv' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq | wc -l

whois -h whois.radb.net -- '-i origin AS32934' | grep 'route:' | grep -oE '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/?([0-9]{1,2})?' | sort | uniq | wc -l

awk -F "," -v COUNTRY_CODE="RU" -v IPSET_TABLE="BANNED_RANGES" -v IPSET_TIMEOUT="86400" '$5 ~ COUNTRY_CODE { gsub(/"/, "", $1); gsub(/"/, "", $2); print "add " IPSET_TABLE " " $1 "-" $2 " timeout " IPSET_TIMEOUT; }' "GeoIPCountryWhois.csv"

awk -F "," -v COUNTRY_CODE="RU" -v IPSET_TABLE="BANNED_RANGES" -v IPSET_TIMEOUT="86400" '$5 ~ COUNTRY_CODE { gsub(/"/, "", $1); gsub(/"/, "", $2); print "add " IPSET_TABLE " " $1 "-" $2 " timeout " IPSET_TIMEOUT; }' "GeoLite2-ASN-Blocks-IPv4.csv"
