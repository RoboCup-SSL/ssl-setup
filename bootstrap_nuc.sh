#!/bin/bash

# This script will bootstrap a fresh Ubuntu 18.04 LTS installation with the latest ssl software
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
sudo apt install -y vim terminator git chrony net-tools vnc4server openssh-server

sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.usbfs_memory_mb=1000"/' /etc/default/grub
sudo update-grub

if [[ -f "spinnaker-1.23.0.27-amd64-Ubuntu18.04-pkg.tar.gz" ]]; then
	if [[ ! -d "spinnaker-1.23.0.27-amd64" ]]; then
		tar xf "spinnaker-1.23.0.27-amd64-Ubuntu18.04-pkg.tar.gz"
		cd spinnaker-1.23.0.27-amd64
		./install_spinnaker.sh
	fi
else
	echo "Put the spinnaker SDK to the ssl-config dir"
	exit 1
fi

# ssl-vision
mkdir -p ~/git
cd ~/git
if [ ! -d ssl-vision ]; then
	git clone http://github.com/RoboCup-SSL/ssl-vision.git
fi
cd ssl-vision
git pull
sudo ./InstallPackagesUbuntu.sh
mkdir -p build
cd build
cmake -DUSE_SPINNAKER=true ..
cd ..
make -j`nproc`

# setting up chrony
# accept all IPv4 connections
sudo sed -ie 's/#allow 0\/0/allow 0\/0/' /etc/chrony/chrony.conf
# server time even if unsynchronized
sudo sed -ie 's/#local stratum/local stratum/' /etc/chrony/chrony.conf
sudo systemctl restart chrony.service
echo "TODO you have to select one computer as the chrony server and add the IP to all other computers in /etc/chrony/chrony.conf as 'server 192.168.178.51'"
read

