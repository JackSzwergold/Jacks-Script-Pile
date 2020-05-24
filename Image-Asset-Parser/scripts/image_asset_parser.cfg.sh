#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# How nice should the script be to other processes: 0-19
NICENESS=19

# Sets a pause for the times ImageMagick functions choke.
SLEEPINESS=0.125

# Set the file extensions array.
FILE_EXTENSIONS_ARRAY=();
FILE_EXTENSIONS_ARRAY[0]='JPG';
FILE_EXTENSIONS_ARRAY[1]='JPEG';
FILE_EXTENSIONS_ARRAY[2]='PNG';
FILE_EXTENSIONS_ARRAY[3]='TIF';
FILE_EXTENSIONS_ARRAY[4]='TIFF';

# Join the array values to set the file extensions to check.
FILE_EXTENSIONS=$(IFS=$'|'; echo "${FILE_EXTENSIONS_ARRAY[*]}")

# Get the current working directory.
CURRENT_WORKING_DIRECTORY=$(pwd)

# Set the base script directory.
BASE_SCRIPT_DIR="${CURRENT_WORKING_DIRECTORY}/"

# Set the base working directory.
BASE_WORKING_DIR="${CURRENT_WORKING_DIRECTORY}/../"

# Set the log file.
BASH_LOGFILE="${BASE_WORKING_DIR}logs/image_asset_bash_process.log"
BASH_LOGFILE=$(cd $(dirname "${BASH_LOGFILE}"); pwd)/$(basename "${BASH_LOGFILE}")

# Set the source directory.
SOURCE_DIR="${BASE_WORKING_DIR}/asset_source"
SOURCE_DIR=$(cd $(dirname "${SOURCE_DIR}"); pwd)/$(basename "${SOURCE_DIR}")

# Set the destination directory.
DESTINATION_DIR="${BASE_WORKING_DIR}/asset_destination"
DESTINATION_DIR=$(cd $(dirname "${DESTINATION_DIR}"); pwd)/$(basename "${DESTINATION_DIR}")

# Set the full path to binary files.
EXIFTOOL_BIN='/usr/bin/exiftool'
CONVERT_BIN='/usr/local/bin/convert'
IDENTIFY_BIN='/usr/local/bin/identify'

# Set what file formats EXIF data will be exported to.
EXPORT_EXIF_JSON_FILE=true
EXPORT_EXIF_TXT_FILE=false
EXPORT_EXIF_XML_FILE=false

# Set whether we are generating a thumbnail or not.
GENERATE_THUMBNAIL=true

# Set the path to the image asset receiver.
IMAGE_ASSET_RECEIVER="${BASE_SCRIPT_DIR}image_asset_receiver.php"
