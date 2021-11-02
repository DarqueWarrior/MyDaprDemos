#!/usr/bin/env bash

# Install AZ CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | /bin/bash

 # Install aws CLI
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 unzip awscliv2.zip
 ./aws/install

 # Install gcloud CLI
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 

apt-get update

apt-get install google-cloud-sdk -y
