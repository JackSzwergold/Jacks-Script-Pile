#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the unique server name.
# SERVER_NAME="${HOSTNAME}";

# Set the suffix using date & time info.
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
SUFFIX='-'${DATE}'-'${TIME};

# Set the source connection, path & destination.
SOURCE_CONNECTION='some_guy@some_server.local'
SOURCE_PASSWORD='some_guys_password'
SOURCE_PATH='/home/some_guy/some_thing_to_get'

# Set the destination path.
DESTINATION_PATH='/Users/jack/Desktop/things_gotten'
DESTINATION_FULL=${DESTINATION_PATH}'/some_thing_to_get'$SUFFIX

# Set the expiration minutes for GZip archives.
EXP_MINUTES=$(((24*60)/4));






