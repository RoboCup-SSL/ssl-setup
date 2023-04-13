#!/usr/bin/env bash
set -euo pipefail

# This script will configure everything that is required to run SSL vision on an Intel NUC.
# You will have to confirm some steps manually, as this script has no control over some installation scripts
#
# Note: Consider updating the NUCs BIOS:
# https://www.intel.com/content/www/us/en/download/18838/bios-update-bnkbl357.html?wapkw=nuc7i7bnh

# determine current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

"${SCRIPT_DIR}"/configure-ubuntu.sh
"${SCRIPT_DIR}"/configure-hostname.sh
"${SCRIPT_DIR}"/configure-chrony.sh
"${SCRIPT_DIR}"/configure-vnc.sh
"${SCRIPT_DIR}"/configure-spinnaker.sh
"${SCRIPT_DIR}"/configure-ssl-vision.sh
