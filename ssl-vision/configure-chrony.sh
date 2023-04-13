#!/usr/bin/env bash
set -euo pipefail

# Install chrony for time synchronization. This is required for setup with more than one NUC / camera.
# ssl-vision uses the system time in detection frames and teams can use those times to coordinate detection frames from different computers / cameras.

# determine current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

echo
echo "### Install and configure Chrony"
echo
sudo apt-get install -y chrony

# Create a backup
mkdir -p "${SCRIPT_DIR}/backup"
cp /etc/chrony/chrony.conf "${SCRIPT_DIR}/backup/chrony.conf.$(date +%s)"

# Replace chrony.conf
sudo cp "${SCRIPT_DIR}/chrony.conf" /etc/chrony/chrony.conf

# restart chrony daemon
sudo systemctl restart chronyd.service

echo "You have to select one computer as the time server and add the IP to all other computers in /etc/chrony/chrony.conf as 'server 192.168.178.51'"
echo -n "Enter an IP to add now (leave it empty otherwise): "
read -r ip
if [[ -n "${ip}" ]]; then
  echo "Adding server to /etc/chrony/chrony.conf"
  echo "server $ip" | sudo tee -a /etc/chrony/chrony.conf
fi
