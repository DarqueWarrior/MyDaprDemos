# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.192.0/containers/codespaces-linux/.devcontainer/base.Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal

USER root

RUN wget -q https://dot.net/v1/dotnet-install.sh -O - | /bin/bash -s - -Channel 6.0.1xx -Quality preview --install-dir $DOTNET_ROOT

# Install Dapr CLI
RUN wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

USER codespace