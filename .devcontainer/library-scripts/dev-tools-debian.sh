#!/usr/bin/env bash

wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get update

# Install .net 6
apt-get install -y software-properties-common apt-transport-https gnupg2 dotnet-sdk-6.0

dotnet tool install --tool-path /bin Microsoft.Tye --version "0.11.0-alpha.22111.1"

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

# Install Helm
wget -q https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -O - | /bin/bash

# Install terraform 
apt-get install -y terraform

# Install Microsoft Open SDK
wget https://aka.ms/download-jdk/microsoft-jdk-11.0.11.9.1-linux-x64.tar.gz -O msopenjdk11.tar.gz && \
    tar zxvf msopenjdk11.tar.gz && \
    rm -rf msopenjdk11.tar.gz /var/lib/apt/lists/*

# Install Maven
wget https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz -O maven.tar.gz && \
    tar zxvf maven.tar.gz && \
    rm -rf maven.tar.gz /var/lib/apt/lists/*

# Install PIP3
apt-get update
apt-get install -y python3-pip

# Install NodeJS
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - &&\
apt-get install -y nodejs