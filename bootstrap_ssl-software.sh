#!/bin/bash

# This script will bootstrap a fresh Ubuntu 16.04 LTS installation with the latest ssl software
# You will have to confirm some steps manually, as this script has no control over some installation scripts

# exit on failures
set -e
# print commands
set -x

# references
# https://github.com/Robocup-SSL

# update system
sudo apt -y update
sudo apt -y dist-upgrade

# install some common dependencies
sudo apt install -y vim terminator openjdk-8-jdk maven git golang chrony

# setup GO
echo "export GOPATH=~/go" >> ~/.bashrc
echo "export PATH=\$GOPATH/bin:\$PATH" >> ~/.bashrc
. ~/.bashrc

# blue fox camera support
# The links below may not work (e.g. version changed in the mean time). You can download the software manually:
# https://www.matrix-vision.com/software-drivers-en.html
wget https://www.matrix-vision.com/software-drivers-en.html?file=tl_files/mv11/support/mvIMPACT_Acquire/01/install_mvBlueFOX.sh -O install_mvBlueFOX.sh
wget https://www.matrix-vision.com/software-drivers-en.html?file=tl_files/mv11/support/mvIMPACT_Acquire/01/mvBlueFOX-x86_64_ABI2-2.26.0.tgz -O mvBlueFOX-x86_64_ABI2-2.26.0.tgz
chmod +x install_mvBlueFOX.sh 
./install_mvBlueFOX.sh

# ssl-vision
mkdir -p ~/git
cd ~/git
git clone http://github.com/RoboCup-SSL/ssl-vision.git
cd ssl-vision
./InstallPackagesUbuntu.sh
make

# ssl-refbox
mkdir -p ~/git
cd ~/git
git clone http://github.com/RoboCup-SSL/ssl-refbox.git
cd ssl-refbox
sudo ./installDeps.sh
make

# ssl-logtools
sudo apt install -y libboost-program-options-dev
mkdir -p ~/git
cd ~/git
git clone https://github.com/RoboCup-SSL/ssl-logtools.git
cd ssl-logtools
mkdir build
cd build
cmake ..
make 


# autoref consensus
go get -u github.com/RoboCup-SSL/ssl-autoref-consensus

# ssl-status-board
go get -u github.com/RoboCup-SSL/ssl-status-board-server/ssl-status-board-proxy

# autorefs
mkdir -p ~/git
cd ~/git
git clone http://github.com/RoboCup-SSL/ssl-autorefs.git
cd ssl-autorefs
sudo ./installDeps.sh
./buildAll.sh

# setting up chrony
# accept all IPv4 connections
sudo sed -ie 's/#allow 0\/0/allow 0\/0/' /etc/chrony/chrony.conf
# server time even if unsynchronized
sudo sed -ie 's/#local stratum/local stratum/' /etc/chrony/chrony.conf
sudo systemctl restart chrony.service
echo "TODO you have to select one computer as the chrony server and add the IP to all other computers in /etc/chrony/chrony.conf as 'server 192.168.178.51'"
read

