#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo
echo "### Clone and build ssl-vision"
echo

target_folder=~/ssl-vision
if [ ! -d "${target_folder}" ]; then
	git clone https://github.com/RoboCup-SSL/ssl-vision.git "${target_folder}"
fi
cd "${target_folder}"
git pull
./InstallPackagesUbuntu.sh
make configure_spinnaker
make -j "$(nproc)"

# Add ssl-vision start script to Autostart
mkdir -p ~/.config/autostart
cp "$SCRIPT_DIR/Vision.desktop" ~/.config/autostart/
