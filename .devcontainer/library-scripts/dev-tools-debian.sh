#!/usr/bin/env bash

apt-get update

apt-get install software-properties-common -y

# Install .net 6
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet

wget -q https://aka.ms/install-dotnet-preview -O - | /bin/bash -s - --install-dir $DOTNET_ROOT

# Install Dapr CLI
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Install K3d CLI
 wget -q https://raw.githubusercontent.com/rancher/k3d/main/install.sh -O - | /bin/bash

 # Install terraform
 curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
 apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
 apt-get update
 apt-get install terraform -y