#!/bin/bash

# Set OS specific variables.
if [[ "$OSTYPE" =~ ^darwin ]]; then
  # For OS X
  MD5_COMMAND='md5 -r' # Command for the the MD5 util.
  STAT_FILE_SIZE='-f %z' # Stat params to get the file size.
  FIND_OPTIONS='-E' # Find command with 'E'xtended regular expressions.
  FIND_REGEXTYPE='' # Find command.
else
  # For Linux
  MD5_COMMAND='md5sum' # Command for the the MD5 util.
  STAT_FILE_SIZE='-c %s' # Stat params to get the file size.
  FIND_OPTIONS='' # Find command.
  FIND_REGEXTYPE='-regextype posix-extended' # Find command.
fi

# Set the root directory.
ROOT_DIR_PATH='/Volumes/Moon'

# Set the directory array.
DIRECTORY_ARRAY=();
DIRECTORY_ARRAY[0]='Research';
DIRECTORY_ARRAY[1]='VirtualBox VMs';

LOG_PATH='/Users/jack/Desktop/'
LOG_PREFIX='Moon'
LOG_DIR_SUFIX='disk_usage_reports'

FIND_MAXDEPTH='18'
FIND_MTIME='-7'
FIND_SIZE='+10M'


