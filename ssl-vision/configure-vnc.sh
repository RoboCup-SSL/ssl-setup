#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo
echo "### Configure VNC"
echo

# Install required packages
sudo apt-get install -y xserver-xorg-video-dummy x11vnc

# Set VNC password
sudo x11vnc -storepasswd vision /etc/x11vnc.pass

# Install VNC service and let it start on boot
sudo cp "${SCRIPT_DIR}/x11vnc.service" /etc/systemd/system/x11vnc.service
sudo systemctl enable x11vnc.service
sudo systemctl daemon-reload
sudo systemctl start x11vnc

# Add custom xorg config that disables the native screen in favor of the VNC screen with correct resolution
sudo cp "${SCRIPT_DIR}/90-dummy-monitor.conf" /usr/share/X11/xorg.conf.d/90-dummy-monitor.conf
