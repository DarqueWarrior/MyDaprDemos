#!/bin/bash 
 
echo "on-create start" >> ~/status

# initialize dapr
dapr init

# log into azure cli
az login --service-principal -t $TENANT -u $APPID -p $PASSWORD

# set the subscription
az account set -s $SUBID

# set defaults
az config set core.output=table

# install PowerShell modules
pwsh -Command "& {Install-Module -Name Trackyon.Utils, VSTeam, powershell-yaml -Force}"
 
echo "on-create complete" >> ~/status