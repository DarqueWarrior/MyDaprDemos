#!/bin/bash 
 
echo "on-create start" >> ~/status
 
# install dapr cli
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
 
# initialize dapr
dapr init

# log into azure cli
az login --service-principal -t $TID -u $SPID -p $SPKEY

# set the subscription
az account set -s $SUBID
 
echo "on-create complete" >> ~/status