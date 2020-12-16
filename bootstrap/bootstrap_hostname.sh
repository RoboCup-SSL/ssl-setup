#!/bin/bash

# exit on failures
set -euo pipefail
# print commands
set -x


echo -n "Enter hostname or keep empty"
read -r hostname
if [[ -n "$hostname" ]]; then
        echo "$hostname" | sudo tee /etc/hostname
        echo "Set hostname to $hostname"
fi
