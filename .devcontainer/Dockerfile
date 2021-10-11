# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.192.0/containers/codespaces-linux/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal

USER root

# Install .net 6
RUN wget -q https://dot.net/v1/dotnet-install.sh -O - | /bin/bash -s - -Channel 6.0.1xx -Quality preview --install-dir $DOTNET_ROOT

# Install Dapr CLI
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Install K3d CLI
 RUN wget -q https://raw.githubusercontent.com/rancher/k3d/main/install.sh -O - | /bin/bash

USER codespace

# Install Tye
RUN dotnet tool install -g Microsoft.Tye --version "0.10.0-alpha.21420.1"
RUN dotnet tool install -g Microsoft.Web.LibraryManager.Cli