# This file is not used in the devcontainer.json file. The images built from it is. If you want to customize this image you need to
# update the devcontainer.json to point to this dockerfile instead of the prebuilt image. Replace the image element with the block
# below.

# "build": {
# 	"dockerfile": "Dockerfile"
# },

# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.192.0/containers/codespaces-linux/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal

USER root

# Install .net 6
RUN wget -q https://dot.net/v1/dotnet-install.sh -O - | /bin/bash -s - -Channel 6.0.1xx -Quality preview --install-dir $DOTNET_ROOT

# Install Dapr CLI
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Install K3d CLI
 RUN wget -q https://raw.githubusercontent.com/rancher/k3d/main/install.sh -O - | /bin/bash

 # Install terraform
 RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && apt install terraform

 # Install aws CLI
 RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

 # Install gcloud CLI
 RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && apt-get update -y && apt-get install google-cloud-sdk -y

USER codespace

# Install Tye
RUN dotnet tool install -g Microsoft.Tye --version "0.10.0-alpha.21420.1"
RUN dotnet tool install -g Microsoft.Web.LibraryManager.Cli