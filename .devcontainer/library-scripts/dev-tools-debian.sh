#!/usr/bin/env bash

# Install .net 6
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet

wget -q https://aka.ms/install-dotnet-preview -O - | /bin/bash -s - --install-dir $DOTNET_ROOT