#!/bin/bash 
 
echo "on-create start" >> ~/status

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

# create cluster using network and registry
k3d cluster create demo-cluster --registry-use k3d-registry.localhost:5500 --network k3d --api-port 6443 -p 30000-30001:30000-30001@server:0

# You can now use the registry like this (example):
# 1. create a new cluster that uses this registry
# k3d cluster create --registry-use k3d-registry.localhost:5500

# 2. tag an existing local image to be pushed to the registry
# docker tag nginx:latest k3d-registry.localhost:5500/mynginx:v0.1

# 3. push that image to the registry
# docker push k3d-registry.localhost:5500/mynginx:v0.1

# 4. run a pod that uses this image
# kubectl run mynginx --image k3d-registry.localhost:5500/mynginx:v0.1

# initialize dapr
dapr init

# initialize dapr in K8s
dapr init -k

# log into azure cli
az login --service-principal -t $TENANT -u $APPID -p $PASSWORD

# set the subscription
az account set -s $SUBID

# set defaults
az config set core.output=table

# install PowerShell modules
pwsh -Command "& {Install-Module -Name Trackyon.Utils, VSTeam, powershell-yaml -Force}"
 
echo "on-create complete" >> ~/status