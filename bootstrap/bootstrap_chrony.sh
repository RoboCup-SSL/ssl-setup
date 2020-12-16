#!/bin/bash

# exit on failures
set -euo pipefail
# print commands
set -x
# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


# Create a backup
mkdir -p "${SCRIPT_DIR}/backup"
cp /etc/chrony/chrony.conf "${SCRIPT_DIR}/backup/chrony.conf.$(date +%s)"

# Replace chrony.conf
sudo cp "${SCRIPT_DIR}/chrony.conf" /etc/chrony/chrony.conf

# restart chrony daemon
sudo systemctl restart chronyd.service

echo "TODO you have to select one computer as the chrony server and add the IP to all other computers in /etc/chrony/chrony.conf as 'server 192.168.178.51'"
read -r
