#!/usr/bin/env bash
set -euo pipefail

echo
echo "### Configure hostname"
echo
if grep "ssl-vision" /etc/hostname >/dev/null; then
  echo "Current hostname is $(cat /etc/hostname), which looks fine."
  exit 0
fi

echo -n "Enter hostname or keep empty to keep the current one: $(cat /etc/hostname)"
read -r hostname
if [[ -n "$hostname" ]]; then
  echo "$hostname" | sudo tee /etc/hostname
  echo "Set hostname to $hostname"
fi
