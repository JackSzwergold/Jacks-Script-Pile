#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the unique server name.
SERVER_NAME="${HOSTNAME}";

# Set the backup destination.
SYNC_DESTINATION_ARRAY=();
SYNC_DESTINATION_ARRAY[0]='some_user@remote_host.local';

# Set the bandwidth kilobits per second.
BANDWIDTH_KBPS=3000

# Set the expiration.
EXP_MINUTES=$(((24*60)/2));