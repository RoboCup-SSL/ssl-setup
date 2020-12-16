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
sudo apt install -y vim terminator git chrony net-tools vnc4server openssh-server xserver-xorg-video-dummy-hwe-18.04 qt5-default linux-lowlatency-hwe-18.04

# Add custom xorg config that disables the native screen in favor of the VNC screen with correct resolution
sudo cp "${SCRIPT_DIR}/90-dummy-monitor.conf" /usr/share/X11/xorg.conf.d/90-dummy-monitor.conf
# Remove old obsolete config file (added by a previous version of this script)
sudo rm -f /usr/share/X11/xorg.conf.d/xorg.conf
