#!/usr/bin/env bash

wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.1/powershell_7.3.1-1.deb_amd64.deb
dpkg -i powershell_7.3.1-1.deb_amd64.deb

rm ./powershell_7.3.1-1.deb_amd64.deb