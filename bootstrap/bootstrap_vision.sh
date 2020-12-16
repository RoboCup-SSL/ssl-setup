#!/bin/bash

# exit on failures
set -euo pipefail
# print commands
set -x
# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# Clone and build ssl-vision
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
cmake -DUSE_SPINNAKER=true -DUSE_QT5=true ..
cd ..
make -j "$(nproc)"

# Add ssl-vision start script to Autostart
mkdir -p ~/.config/autostart
cp "$SCRIPT_DIR/Vision.desktop" ~/.config/autostart/
