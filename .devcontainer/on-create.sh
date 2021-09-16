#!/bin/bash 
 
echo "on-create start" >> ~/status
 
# install dapr cli
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
 
# initialize dapr
dapr init

# log into azure cli
az login --service-principal -t $TENANT -u $APPID -p $PASSWORD

# set the subscription
az account set -s $SUBID

# set defaults
az config set core.output=table

# install PowerShell modules
pwsh -Command "& {Install-Module -Name Trackyon.Utils, VSTeam -Force}"

# install .net 6
wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O - | /bin/bash -s - --channel 6.0.1xx --quality preview --install-dir ~/.dotnet
 
echo "on-create complete" >> ~/status