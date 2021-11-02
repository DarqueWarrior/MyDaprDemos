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
 apt install terraform

 # Install aws CLI
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 unzip awscliv2.zip
 ./aws/install

 # Install gcloud CLI
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 
apt-get update -y
apt-get install google-cloud-sdk -y
