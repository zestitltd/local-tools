#!/bin/bash

STATUSFOLDER=/root/.replication_status						# It will store files to track when last error notification been sent
REPLICATION_ERROR_STATUS_DELAY=3600						# Delay between error notifications

IP=`/sbin/ifconfig | /bin/sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`	# Server IP

DEBUG=0										# Will output debugging messages if 1

# Making sure we have folder to store last notification time
if [ ! -d $STATUSFOLDER ] ; then
  if [ $DEBUG = 1 ] ; then echo "Creating folder: $STATUSFOLDER" ; fi
  mkdir $STATUSFOLDER
fi

if [ $DEBUG = 1 ] ; then echo "Retrieing status for $IP" ; fi

FILE=$STATUSFOLDER/$IP'.check'

RESPONSE=`/home/lemon_backup/mysqlreplicationstatus.sh`

if [ $DEBUG = 1 ] ; then echo "Response: $RESPONSE" ; fi

if [ ! $RESPONSE = 0 ]; then
  CREATED=$(/var/lib/local-tools/past_since_modified.sh $FILE)

  if [ $DEBUG = 1 ] ; then echo -e "Replication error\nFile created $CREATED seconds ago. Notification delay is $REPLICATION_ERROR_STATUS_DELAY seconds" ; fi
  if [ $DEBUG = 1 ] && [ "$CREATED" -gt "$REPLICATION_ERROR_STATUS_DELAY" ] ; then echo 'It is time to send notification.' ; fi

  if [ ! -f $FILE ] || [ "$CREATED" -gt "$REPLICATION_ERROR_STATUS_DELAY" ] ; then
    echo "Replication is down on $IP. Check MySQL logs."
    echo $RESPONSE > $FILE
  fi
else
  if [ -f $FILE ] ; then
    if [ $DEBUG = 1 ] ; then echo "Issue been resolved. Removing $FILE" ; fi
    rm $FILE
  fi
fi
