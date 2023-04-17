#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

readonly goos="linux"
readonly goarch="amd64"
readonly target_folder="$HOME/.local/bin"
readonly config_folder="$HOME/.config"
readonly systemd_folder="$HOME/.local/share/systemd/user"

function latest_version() {
  local -r repo="$1"
  curl -s "https://api.github.com/repos/RoboCup-SSL/${repo}/releases/latest" | jq -r '.tag_name'
}

function update_app() {
  local -r repo="$1"
  local -r app="$2"
  local version
  version="$(latest_version "${repo}")"
  echo "Latest version of ${app} from ${repo} is ${version}"
  binary_name="${app}_${version}_${goos}_${goarch}"
  if [[ ! -f "${binary_name}" ]]; then
    echo "Downloading ${binary_name}"
    curl --location --silent "https://github.com/RoboCup-SSL/${repo}/releases/download/${version}/${binary_name}" --output "${binary_name}"
    chmod +x "${binary_name}"
    rm -f "${app}"
    ln -s "${binary_name}" "${app}"

    if [[ -f "${SCRIPT_DIR}/systemd/${app}.service" ]]; then
      if ! systemctl --user | grep "${app}.service" >/dev/null; then
        echo "Installing service for ${app}"
        mkdir -p "${systemd_folder}"
        cp "${SCRIPT_DIR}/systemd/${app}.service" "${systemd_folder}"
        mkdir -p "${config_folder}/${app}"
        systemctl --user enable "${app}.service"
        systemctl --user daemon-reload
      fi
      echo "Restarting service for ${app}"
      systemctl --user restart "${app}.service"
    fi
  fi
}

mkdir -p "${target_folder}"
cd "${target_folder}"
update_app ssl-game-controller ssl-game-controller
update_app ssl-game-controller ssl-ref-client
update_app ssl-go-tools ssl-auto-recorder
update_app ssl-vision-client ssl-vision-client
update_app ssl-vision-client ssl-vision-cli
