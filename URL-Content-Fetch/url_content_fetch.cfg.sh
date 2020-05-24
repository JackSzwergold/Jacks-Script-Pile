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

# Set the content URLs.
CONTENT_URL_ARRAY=();
CONTENT_URL_ARRAY[0]='http://www.preworn.com/genius_stuff/moe';
CONTENT_URL_ARRAY[1]='http://www.preworn.com/genius_stuff/larry';
CONTENT_URL_ARRAY[2]='http://www.preworn.com/genius_stuff/curly';

# Set the destination path
DESTINATION_PATH='/Users/jack/Desktop/fetched_content';

# Set the expiration minutes for GZip archives.
EXP_MINUTES=$(((24*60)/4));