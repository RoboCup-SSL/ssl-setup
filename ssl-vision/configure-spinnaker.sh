#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

echo
echo "### Configure Spinnaker"
echo

# List of documentation for FLIR Blackfly cameras:
# https://www.flir.de/support-center/iis/machine-vision/knowledge-base/technical-documentation-blackfly-s-usb3/

# Download latest Spinnaker SDK (requires a free account):
# https://www.flir.de/products/spinnaker-sdk/

readonly spinnaker_version="3.0.0.118"
readonly spinnaker_archive="spinnaker-${spinnaker_version}-amd64-pkg.tar.gz"
readonly spinnaker_archive_path="${SCRIPT_DIR}/${spinnaker_archive}"
if [[ ! -f "${spinnaker_archive_path}" ]]; then
  wget -O "${spinnaker_archive_path}" "https://cloud.robocup.org/s/DoQqtmnrq8pNYCc/download/${spinnaker_archive}"
fi

# Install Spinnaker driver for FLIR camera
if [[ ! -f "${spinnaker_archive_path}" ]]; then
  echo "Spinnaker SDK archive not found: ${spinnaker_archive_path}" >&2
  exit 1
fi

readonly spinnaker_folder="${SCRIPT_DIR}/spinnaker-${spinnaker_version}-amd64"
if [[ ! -d "${spinnaker_folder}" ]]; then
  tar xvf "${spinnaker_archive_path}" -C "${SCRIPT_DIR}"
  cd "${spinnaker_folder}"
  ./install_spinnaker.sh
fi
