#!/usr/bin/env bash
set -euo pipefail

echo
echo "### Update System"
echo
sudo apt-get -y update
sudo apt-get -y dist-upgrade

echo
echo "### Install some common dependencies"
echo
sudo apt-get install -y neovim git net-tools openssh-server
