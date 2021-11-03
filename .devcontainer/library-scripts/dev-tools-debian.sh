#!/usr/bin/env bash

apt-get update

apt-get install -y software-properties-common apt-transport-https gnupg2

# Install .net 6
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet

wget -q https://aka.ms/install-dotnet-preview -O - | /bin/bash -s - --install-dir $DOTNET_ROOT

# Install Dapr CLI
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Install K3d CLI
wget -q https://raw.githubusercontent.com/rancher/k3d/main/install.sh -O - | /bin/bash

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update

# Install kubectl
apt-get install -y kubectl

# Install terraform 
apt-get install -y terraform