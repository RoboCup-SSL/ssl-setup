#!/bin/bash

# exit on failures
set -euo pipefail
# print commands
set -x
# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# Increase USB FS memory (required for USB3 cameras)
sudo sed -ie 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.usbfs_memory_mb=1000"/' /etc/default/grub
# Check if it worked
grep "usbfs_memory_mb=1000" /etc/default/grub || exit 1
sudo update-grub

# Install Spinnaker driver for FLIR camera
if [[ -f "${SCRIPT_DIR}/spinnaker-1.23.0.27-amd64-Ubuntu18.04-pkg.tar.gz" ]]; then
	if [[ ! -d "${SCRIPT_DIR}/spinnaker-1.23.0.27-amd64" ]]; then
		tar xf "${SCRIPT_DIR}/spinnaker-1.23.0.27-amd64-Ubuntu18.04-pkg.tar.gz"
		cd "${SCRIPT_DIR}/spinnaker-1.23.0.27-amd64"
		./install_spinnaker.sh
	fi
else
	echo "Put the spinnaker SDK to the ssl-config dir"
	exit 1
fi
