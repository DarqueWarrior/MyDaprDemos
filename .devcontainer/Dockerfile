# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.192.0/containers/codespaces-linux/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal

USER root

# Install Dapr CLI
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Install DotNet 6
RUN mkdir $HOME/dotnet_install && cd $HOME/dotnet_install && curl -L https://aka.ms/install-dotnet-preview -o install-dotnet-preview.sh && bash install-dotnet-preview.sh

USER codespace