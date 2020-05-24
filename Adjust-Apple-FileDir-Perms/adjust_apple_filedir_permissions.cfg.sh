#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# Set the debug mode.
DEBUG_MODE=true

# Set the root directory path.
ROOT_DIR_PATH='/Volumes/Moon/'

# Set the directory array.
DIRECTORY_ARRAY=();
DIRECTORY_ARRAY[0]='Research';

# Set the permissions & ownership values.
CHMOD_DIR='0770'
CHMOD_FILE='0660'
CHOWN_USER='jack'
CHGRP_GROUP='staff'