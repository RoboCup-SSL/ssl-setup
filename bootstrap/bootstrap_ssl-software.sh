#!/bin/bash

# exit on failures
set -euo pipefail
# print commands
set -x
# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# update system
sudo apt -y update
sudo apt -y dist-upgrade

# install some common dependencies
sudo apt install -y vim terminator openjdk-8-jdk git golang chrony net-tools

# setup GO
if ! grep -q GOPATH ~/.bashrc; then
	echo "export GOPATH=~/go" >> ~/.bashrc
	echo "export PATH=\$GOPATH/bin:\$PATH" >> ~/.bashrc
	. ~/.bashrc
fi

# Clone and build ssl-vision without Spinnaker (mainly for graphical client)
mkdir -p ~/git
cd ~/git
if [ ! -d ssl-vision ]; then
	git clone http://github.com/RoboCup-SSL/ssl-vision.git
fi
cd ssl-vision
git pull
./InstallPackagesUbuntu.sh
mkdir -p build
cd build
cmake -DUSE_QT5=true ..
cd ..
make -j "$(nproc)"

# ssl-status-board
go get -u github.com/RoboCup-SSL/ssl-status-board-server/...

# ssl recorder
go get -u github.com/RoboCup-SSL/ssl-go-tools/ssl-recorder

# autorefs
mkdir -p ~/git
cd ~/git
if [ ! -d ssl-autorefs ]; then
	git clone http://github.com/RoboCup-SSL/ssl-autorefs.git
fi
cd ssl-autorefs
git pull
git submodule update
sudo ./installDeps.sh
./buildAll.sh

# setting up chrony
./"${SCRIPT_DIR}"/bootstrap_chrony.sh
