#!/bin/bash

USER=lemon_backup
PEM='/root/.ssh/lemon_backup'

# Main 1 VPS
IP='52.62.67.66'

ssh ${USER}@$IP -i $PEM 'touch /var/lib/mysqlbackup/placeholder'
ssh ${USER}@$IP -i $PEM 'rm -r /var/lib/mysqlbackup/*'
ssh ${USER}@$IP -i $PEM '~/mysqlbackup.sh'
ssh ${USER}@$IP -i $PEM 'gzip -r /var/lib/mysqlbackup/'

# Loadrite 1 VPS
IP='52.9.79.22'

ssh ${USER}@$IP -i $PEM 'touch /var/lib/mysqlbackup/placeholder'
ssh ${USER}@$IP -i $PEM 'rm -r /var/lib/mysqlbackup/*'
ssh ${USER}@$IP -i $PEM '~/mysqlbackup.sh'
ssh ${USER}@$IP -i $PEM 'gzip -r /var/lib/mysqlbackup/'

# Loadrite 2 VPS
IP='52.9.79.102'

ssh ${USER}@$IP -i $PEM 'touch /var/lib/mysqlbackup/placeholder'
ssh ${USER}@$IP -i $PEM 'rm -r /var/lib/mysqlbackup/*'
ssh ${USER}@$IP -i $PEM '~/mysqlbackup.sh'
ssh ${USER}@$IP -i $PEM 'gzip -r /var/lib/mysqlbackup/'
