#!/bin/bash 
 
echo "on-create start" >> ~/status

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

# create cluster using network and registry
k3d cluster create demo-cluster --registry-use k3d-registry.localhost:5500 --network k3d --api-port 6443 -p 30000-30001:30000-30001@server:0

# initialize dapr
dapr init

# initialize dapr in K8s
dapr init -k

### Azure
# log into azure cli
az login --service-principal -t $AZURE_TENANT -u $AZURE_APP_ID -p $AZURE_PASSWORD

# set the subscription
az account set -s $AZURE_SUB_ID

# set defaults
az config set core.output=table

### AWS
# set output to table
aws configure set output table

# install PowerShell modules
pwsh -Command "& {Install-Module -Name Trackyon.Utils, VSTeam, powershell-yaml -Force}"
 
echo "on-create complete" >> ~/status