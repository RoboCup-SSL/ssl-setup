#!/bin/bash

# This script will bootstrap a fresh Ubuntu 18.04 LTS installation with everything that is required to run SSL vision
# You will have to confirm some steps manually, as this script has no control over some installation scripts

set -euo pipefail

# Run all bootstrap scripts
./bootstrap_ubuntu.sh
./bootstrap_hostname.sh
./bootstrap_chrony.sh
./bootstrap_spinnaker.sh
./bootstrap_vision.sh
