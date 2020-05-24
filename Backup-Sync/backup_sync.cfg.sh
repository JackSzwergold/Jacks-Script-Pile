#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the unique server name.
SERVER_NAME="${HOSTNAME}";

# Set the bandwidth Kbps.
BANDWIDTH_KBPS=3000

# Set the backup destination.
BACKUP_DEST_ARRAY=();
BACKUP_DEST_ARRAY[0]='someuser@somehost.local';