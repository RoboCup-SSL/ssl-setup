#!/usr/bin/env bash
set -euo pipefail

echo
echo "### Clone and prepare VisionProcessor"
echo

target_folder=~/vision-processor
if [ ! -d "${target_folder}" ]; then
	git clone https://github.com/TIGERs-Mannheim/vision-processor.git "${target_folder}"
fi
cd "${target_folder}"
git pull
./setup.sh

# Add section in the future to add basic configuration for Div A and Div B setups and setup the autostarts accordingly
