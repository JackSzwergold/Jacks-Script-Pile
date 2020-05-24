#!/bin/bash -l

################################################################################
# Configuration options.
################################################################################

DOCUMENT_ROOT='/var/www/';

# Set the server name if needed.
SERVER_NAME="${HOSTNAME}";

DIRECTORY_ARRAY=();
DIRECTORY_ARRAY[0]='builds';
DIRECTORY_ARRAY[1]='configs';
DIRECTORY_ARRAY[2]='content';
DIRECTORY_ARRAY[3]='html';

CHMOD_DIR='0775';
CHMOD_FILE='0664';
CHMOD_EXEC_FILE='0775';
CHMOD_READ_FILE='0444'
CHMOD_DRUPAL_SETTINGS='0440'
CHMOD_DRUPAL_DIR='0755';
CHGRP_USER='apache';
CHGRP_GROUP='www-readwrite';
