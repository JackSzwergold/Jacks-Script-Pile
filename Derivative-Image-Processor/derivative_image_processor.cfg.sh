#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

CHMOD_DIR='0775'
CHMOD_FILE='0664'
CHGRP_GROUP='staff'

# How nice should the script be to other processes: 0-19
NICENESS=19

# Sets a pause for the times ImageMagick functions choke.
SLEEPINESS=0.125

# Set the image logfile path.
DERIVATIVE_IMAGE_PROCESSOR_LOGFILE="/Users/jack/Desktop/derivative_image_processor_media/derivative_image_processor.log"

# Set the base directory.
BASE_DIR='/Users/jack/Desktop/derivative_image_processor_media/'

# Set the final directory.
FINAL_DIR='/Users/jack/Desktop/derivative_image_processor_media/'

# Set the file extensions array.
FILE_EXTENSIONS_ARRAY=();
FILE_EXTENSIONS_ARRAY[0]='jpg';
FILE_EXTENSIONS_ARRAY[1]='JPG';
FILE_EXTENSIONS_ARRAY[2]='jpeg';
FILE_EXTENSIONS_ARRAY[3]='JPEG';
FILE_EXTENSIONS_ARRAY[4]='png';
FILE_EXTENSIONS_ARRAY[5]='PNG';

# Join the array values to set the file extensions to check.
# FILE_EXTENSIONS=$(IFS=$','; echo "${FILE_EXTENSIONS_ARRAY[*]}")
FILE_EXTENSIONS=$(IFS=$'|'; echo "${FILE_EXTENSIONS_ARRAY[*]}")

# Set the base image directories.
HIRES_IMAGE_DIR=${BASE_DIR}'hires'
FULL_IMAGE_DIR=${BASE_DIR}'full'

# Set the derivative image directories.
DERIVATIVE_ARRAY=();
DERIVATIVE_ARRAY[0]='large';
DERIVATIVE_ARRAY[1]='medium';
DERIVATIVE_ARRAY[2]='small';

# Set the full size stuff.
FULL_SIZE_MAX='490';
FULL_SIZE='490x490>'; # full
FULL_QUALITY='-quality 90%'; # full
FULL_RESIZE_METHOD='-resize'; # full
# FULL_SHARPEN='-sharpen 0x1'; # full
FULL_SHARPEN=''; # full
FULL_RESAMPLE='-density 72 '; # full

# Set the derivative image sizes.
SIZE_ARRAY=();
SIZE_ARRAY[0]='300x300>'; # large
SIZE_ARRAY[1]='160x160>'; # medium
SIZE_ARRAY[2]='62x62>'; # small

# Set the derivative image quality.
QUALITY_ARRAY=();
QUALITY_ARRAY[0]='-quality 90%'; # large
QUALITY_ARRAY[1]='-quality 90%'; # medium
QUALITY_ARRAY[2]='-quality 90%'; # small

# Set the derivative resize method.
RESIZE_METHOD_ARRAY=();
# RESIZE_METHOD_ARRAY[0]='-adaptive-resize'; # large
RESIZE_METHOD_ARRAY[0]='-resize'; # large
RESIZE_METHOD_ARRAY[1]='-resize'; # medium
RESIZE_METHOD_ARRAY[2]='-resize'; # small

# Set the derivative sharpen method.
SHARPEN_ARRAY=();
SHARPEN_ARRAY[0]='-sharpen 0x1'; # large
SHARPEN_ARRAY[1]=''; # medium
SHARPEN_ARRAY[2]=''; # small

# Set the derivative density.
RESAMPLE_ARRAY=();
RESAMPLE_ARRAY[0]='-density 72 '; # large
RESAMPLE_ARRAY[1]='-density 72 '; # medium
RESAMPLE_ARRAY[2]='-density 72 '; # small

# OPTIONS="-colorspace sRGB -strip"
OPTIONS="-colorspace sRGB"

PROCESSED_COUNT=0
