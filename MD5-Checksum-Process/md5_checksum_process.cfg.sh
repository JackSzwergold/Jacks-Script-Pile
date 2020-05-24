#!/bin/bash

##########################################################################################
# Configuration options.
##########################################################################################

# How nice should the script be to other processes: 0-19
NICENESS=19

# Sets a pause for the times ImageMagick functions choke.
SLEEPINESS=0.125

# Set the source root path.
ROOT_PATH='/Users/jack/Desktop/md5_checksum_stuff/'

# Set the CSV output path.
CSV_OUTPUT_PATH='/Users/jack/Desktop/'

# Set the file extensions array.
CHECK_ALL_DIRECTORY_CONTENT=();
CHECK_ALL_DIRECTORY_CONTENT[0]='CHECK_ALL_TEST';

# Set the file extensions array.
FILE_EXTENSIONS_ARRAY=();
FILE_EXTENSIONS_ARRAY[0]='DMG';
FILE_EXTENSIONS_ARRAY[1]='ISO';
FILE_EXTENSIONS_ARRAY[2]='TS';
FILE_EXTENSIONS_ARRAY[3]='PDF';
FILE_EXTENSIONS_ARRAY[4]='VOB';
FILE_EXTENSIONS_ARRAY[5]='IFO';
FILE_EXTENSIONS_ARRAY[6]='BUP';
FILE_EXTENSIONS_ARRAY[7]='EXE';
FILE_EXTENSIONS_ARRAY[8]='JPG';
FILE_EXTENSIONS_ARRAY[9]='JPEG';
FILE_EXTENSIONS_ARRAY[10]='PNG';
FILE_EXTENSIONS_ARRAY[11]='TIF';
FILE_EXTENSIONS_ARRAY[12]='TIFF';
FILE_EXTENSIONS_ARRAY[13]='MOV';
FILE_EXTENSIONS_ARRAY[14]='MP4';
FILE_EXTENSIONS_ARRAY[15]='M4V';
FILE_EXTENSIONS_ARRAY[16]='ZIP';
FILE_EXTENSIONS_ARRAY[17]='MP3';
FILE_EXTENSIONS_ARRAY[18]='WAV';
FILE_EXTENSIONS_ARRAY[19]='AIFF';
FILE_EXTENSIONS_ARRAY[20]='PPT';
FILE_EXTENSIONS_ARRAY[21]='PPTX';
FILE_EXTENSIONS_ARRAY[22]='DOC';
FILE_EXTENSIONS_ARRAY[23]='DOCX';
FILE_EXTENSIONS_ARRAY[24]='XLS';
FILE_EXTENSIONS_ARRAY[25]='XLSX';

# Join the array values to set the file extensions to check.
FILE_EXTENSIONS=$(IFS=$'|'; echo "${FILE_EXTENSIONS_ARRAY[*]}")
