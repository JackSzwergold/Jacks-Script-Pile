#!/bin/bash -l

################################################################################
# Configuration options.
################################################################################

################################################################################
# Set the working directory.
BASE_DIR="/tmp/";

################################################################################
# Set binary variable locations.
# IFCONFIG_BIN=$(which ifconfig);
# IPSET_BIN=$(which ipset);
IFCONFIG_BIN=$(locate ifconfig | grep -m 1 bin);
IPSET_BIN=$(locate ipset | grep -m 1 bin);

################################################################################
# Set IP address manually if network interaface addres is not external
# IP_ADDRESS=$($IFCONFIG_BIN en0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

################################################################################
# Set IP address manually if network interaface address.
# IP_ADDRESS="123.456.789.0"

################################################################################
# If the IP address is empty, we will assume this is am Amazon EC2 server.
if [ -z "${IP_ADDRESS}" ]; then
  IP_ADDRESS=$(curl --silent -L http://169.254.169.254/latest/meta-data/public-ipv4);
fi

################################################################################
# Get the local, internal IP address.
IP_ADDRESS_LOCAL=$(curl --silent -L http://169.254.169.254/latest/meta-data/local-ipv4);

################################################################################
# Set the sundry variables.
CURL_TIMEOUT=30; # 30 second timeout.
IPSET_TIMEOUT=86400; # 1 day timeout.

################################################################################
# Set the IPSet setnames.
SET_TOR_IPS="TOR_IPS";
SET_WHITELIST_IPS="WHITELIST_IPS";
SET_BANNED_RANGES="BANNED_RANGES";
SET_AMAZON_RANGES="AMAZON_RANGES";
SET_MICROSOFT_RANGES="MICROSOFT_RANGES";
SET_ASN_RANGES="ASN_RANGES";

################################################################################
# Set the IPSet setname array.
SETNAME_ARRAY=();
SETNAME_ARRAY[0]=${SET_WHITELIST_IPS};
SETNAME_ARRAY[1]=${SET_TOR_IPS};
SETNAME_ARRAY[2]=${SET_BANNED_RANGES};
SETNAME_ARRAY[3]=${SET_AMAZON_RANGES};
SETNAME_ARRAY[4]=${SET_MICROSOFT_RANGES};
SETNAME_ARRAY[5]=${SET_ASN_RANGES};

################################################################################
# Set the TOR ports.
TOR_PORT_ARRAY=();
TOR_PORT_ARRAY[0]=80;
TOR_PORT_ARRAY[1]=9998;

################################################################################
# Set the TOR URL.
TOR_URL="http://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=";

################################################################################
# Set the AWS URL.
AMAZON_IP_RANGES_URL="https://ip-ranges.amazonaws.com/ip-ranges.json";

################################################################################
# Set the Microsoft URL.
MICROSOFT_IP_RANGES_URL="https://www.microsoft.com/en-us/download/confirmation.aspx?id=41653";

################################################################################
# Set the GeoIP CSVs
GEOIP_COUNTRY_CSV="/usr/local/share/GeoIP/GeoIPCountryWhois.csv";

################################################################################
# Set a country array.
COUNTRY_ARRAY=();
COUNTRY_ARRAY[0]='CN'; # China
COUNTRY_ARRAY[1]='RU'; # Russian Federation
COUNTRY_ARRAY[2]='UA'; # Ukraine
COUNTRY_ARRAY[3]='IN'; # India
COUNTRY_ARRAY[4]='BR'; # Brazil
COUNTRY_ARRAY[5]='VN'; # Vietnam
COUNTRY_ARRAY[6]='KR'; # South Korea
COUNTRY_ARRAY[7]='IR'; # Iran
COUNTRY_ARRAY[8]='HK'; # Hong Kong
COUNTRY_ARRAY[9]='LT'; # Lithuania
COUNTRY_ARRAY[10]='MD'; # Moldova

################################################################################
# Set a country array.
ASN_ARRAY=();
ASN_ARRAY[0]='AS15169'; # Google
ASN_ARRAY[1]='AS32934'; # Facebook
ASN_ARRAY[2]='AS12876'; # Online SAS
ASN_ARRAY[3]='AS14061'; # DigitalOcean
ASN_ARRAY[4]='AS49505'; # Selectel
ASN_ARRAY[5]='AS21859'; # Zenlayer
ASN_ARRAY[6]='AS174'; # Cogent
ASN_ARRAY[7]='AS237'; # Merit
ASN_ARRAY[8]='AS398324'; # Censys
ASN_ARRAY[9]='AS398722'; # Censys
ASN_ARRAY[10]='AS16276'; # OVH SAS
ASN_ARRAY[11]='AS62087'; # Host Europe GmbH
