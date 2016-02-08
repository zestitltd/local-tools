#!/bin/bash

USER=lemon_backup								# User to use for remote connection
PEM='/root/.ssh/lemon_backup'							# SSH key to use for connection

STATUSFOLDER=/root/.replication_status						# It will store files to track when last error notification been sent
REPLICATION_ERROR_STATUS_DELAY=3600						# Delay between error notifications

declare -a IPS=('52.62.67.66' '52.62.89.85' '52.9.79.22' '52.9.79.102')		# Remote servers syd1, syd2, cal1 and cal2

DEBUG=0										# Will output debugging messages if 1

# Making sure we have folder to store last notification time
if [ ! -d $STATUSFOLDER ] ; then
  if [ $DEBUG = 1 ] ; then echo "Creating folder: $STATUSFOLDER" ; fi
  mkdir $STATUSFOLDER
fi

for IP in "${IPS[@]}" ; do
  if [ $DEBUG = 1 ] ; then echo "Retrieing status for $IP" ; fi

  FILE=$STATUSFOLDER/$IP'.check'

  RESPONSE=`ssh ${USER}@$IP -i $PEM '~/mysqlreplicationstatus.sh'`

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
done
