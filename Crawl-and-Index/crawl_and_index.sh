#!/bin/sh

##########################################################################################
#
# Crawl and Index (crawl_and_index.sh) (c) by Jack Szwergold
#
# Crawl and Index is licensed under a
# Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# You should have received a copy of the license along with this
# work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.
#
# w: http://www.preworn.com
# e: me@preworn.com
#
# Created: 2012-05-16, js
# Version: 2012-05-16, js: creation
#          2012-05-16, js: development
#          2012-06-13, js: development
#          2015-10-14, js: development
#
##########################################################################################

LOCK_NAME="CRAWL_AND_INDEX"
LOCK_DIR=/tmp/${LOCK_NAME}.lock
PID_FILE=${LOCK_DIR}/${LOCK_NAME}.pid
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
# SEGMENTS_BACKUP_EXPIRATRION=1
SEGMENTS_BACKUP_EXPIRATRION=180
# NUTCH_DIRECTORY=/usr/share/nutch;
# NUTCH_DIRECTORY=/usr/share/apache-nutch-1.3/runtime/local;
NUTCH_DIRECTORY=/usr/share/apache-nutch-1.4/runtime/local;

if mkdir ${LOCK_DIR} 2>/dev/null; then
  # If the ${LOCK_DIR} doesn't exist, then start working & store the ${PID_FILE}
  echo $$ > ${PID_FILE}

  # This is where the magic happens.
  # Go to the nutch directory.
  cd ${NUTCH_DIRECTORY}

  ##########################################################################################
  # Start by injecting the seed url(s) to the nutch crawldb:
  bin/nutch inject crawl/crawldb urls >/dev/null & INJECT_PID=`jobs -l | awk '{print $2}'`
  wait ${INJECT_PID}

  # Generate a fetch list.
  bin/nutch generate crawl/crawldb crawl/segments >/dev/null & GENERATE_PID=`jobs -l | awk '{print $2}'`
  wait ${GENERATE_PID}

  # Get the directory location of the latest segment.
  # export SEGMENT=crawl/segments/`ls -tr crawl/segments|tail -1`
  export SEGMENT=crawl/segments/$(ls -tr crawl/segments | tail -1)

  # Launch the crawler & fetch the content.
  bin/nutch fetch $SEGMENT -noParsing >/dev/null & FETCH_PID=`jobs -l | awk '{print $2}'`
  wait ${FETCH_PID}

  # Parse the fetched content.
  bin/nutch parse $SEGMENT >/dev/null & PARSE_PID=`jobs -l | awk '{print $2}'`
  wait ${PARSE_PID}

  # Update crawl database to ensure that for all future crawls we only fetch new & changed content.
  bin/nutch updatedb crawl/crawldb $SEGMENT -filter -normalize >/dev/null & UPDATEDB_PID=`jobs -l | awk '{print $2}'`
  wait ${UPDATEDB_PID}

  # Create a link database from the crawled segments.
  bin/nutch invertlinks crawl/linkdb -dir crawl/segments >/dev/null & INVERTLINKS_PID=`jobs -l | awk '{print $2}'`
  wait ${INVERTLINKS_PID}

  ##########################################################################################
  # Index the crawl segments from Nutch with Solr
  bin/nutch solrindex http://localhost:8080/solr/ crawl/crawldb -linkdb crawl/linkdb crawl/segments/* >/dev/null & SOLRINDEX_PID=`jobs -l | awk '{print $2}'`
  wait ${SOLRINDEX_PID}

  # Optimize the index to fully remove duplicates.
  curl http://localhost:8080/solr/update?optimize=true >/dev/null & SOLROPTIMIZE_PID=`jobs -l | awk '{print $2}'`
  wait ${SOLROPTIMIZE_PID}

  ##########################################################################################
  # Merges segments in the 'crawl/segments' directory.
  bin/nutch mergesegs crawl/segments_MERGED crawl/segments/* >/dev/null & MERGESEGS_PID=`jobs -l | awk '{print $2}'`
  wait ${MERGESEGS_PID}

  # Create a backup of the 'crawl/segments' directory.
  mv crawl/segments/* crawl/segments_BACKUP >/dev/null & SEGMENTSBACKUP_PID=`jobs -l | awk '{print $2}'`
  wait ${SEGMENTSBACKUP_PID}

  # Move the merged segments into the main segments directory.
  mv crawl/segments_MERGED/* crawl/segments >/dev/null & MOVEDMERGED_PID=`jobs -l | awk '{print $2}'`
  wait ${MOVEDMERGED_PID}

  # Get rid if the segments_MERGED directory.
  rm -rf crawl/segments_MERGED >/dev/null & SEGMENTSMERGEDCLEANUP_PID=`jobs -l | awk '{print $2}'`
  wait ${SEGMENTSMERGEDCLEANUP_PID}

  # Cleanup the segments backup based on the preset expiration date.
  # find crawl/segments_BACKUP/* -maxdepth 0 -type d -mtime +${SEGMENTS_BACKUP_EXPIRATRION} -name "*" -exec rm -rf {} \;  >/dev/null & SEGMENTSBACKUPCLEANUP_PID=`jobs -l | awk '{print $2}'`
  find crawl/segments_BACKUP/* -maxdepth 0 -type d -mmin +${SEGMENTS_BACKUP_EXPIRATRION} -name "*" -exec rm -rf {} \;  >/dev/null & SEGMENTSBACKUPCLEANUP_PID=`jobs -l | awk '{print $2}'`
  wait ${SEGMENTSBACKUPCLEANUP_PID}

  # Clear out the log
  rm -rf ${LOCK_DIR}
  exit
else
  if [ -f ${PID_FILE} ] && kill -0 $(cat ${PID_FILE}) 2>/dev/null; then
    # Confirm that the process file exists & a process
    # with that PID is truly running.
    # echo "Running [PID "$(cat ${PID_FILE})"]" >&2
    exit
  else
    # If the process is not running, yet there is a PID file--like in the case
    # of a crash or sudden reboot--then get rid of the ${LOCK_DIR}
    rm -rf ${LOCK_DIR}
    exit
  fi
fi
