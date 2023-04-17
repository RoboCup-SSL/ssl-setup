#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

readonly goos="linux"
readonly goarch="amd64"
readonly target_folder="$HOME/.local/bin"
readonly config_folder="$HOME/.config"
readonly systemd_folder="$HOME/.local/share/systemd/user"
declare -A app_repo_map
app_repo_map["ssl-game-controller"]="ssl-game-controller"
app_repo_map["ssl-ref-client"]="ssl-game-controller"
app_repo_map["ssl-auto-recorder"]="ssl-go-tools"
app_repo_map["ssl-vision-client"]="ssl-vision-client"
app_repo_map["ssl-vision-cli"]="ssl-vision-client"

readonly action=${1:-}
readonly param_app=${2:-}

apps=("${!app_repo_map[@]}")
systemd_services=(ssl-game-controller ssl-auto-recorder ssl-vision-client)

if [[ -n "${param_app}" ]]; then
  if [[ -z "${app_repo_map[$param_app]+x}" ]]; then
    echo "Invalid app: ${param_app}" >&2
    exit 1
  fi
  systemd_services=("${param_app}")
  apps=("${param_app}")
fi

function latest_version() {
  local -r repo="$1"
  curl -s "https://api.github.com/repos/RoboCup-SSL/${repo}/releases/latest" | jq -r '.tag_name'
}

function install_app() {
  local -r app="$1"
  local repo="${app_repo_map[${app}]}"
  local version
  version="$(latest_version "${repo}")"
  echo "Latest version of ${app} from ${repo} is ${version}"
  binary_name="${app}_${version}_${goos}_${goarch}"
  binary_path="${target_folder}/${binary_name}"
  if [[ ! -f "${binary_path}" ]]; then
    echo "Downloading ${binary_name}"
    mkdir -p "${target_folder}"
    curl --location --silent "https://github.com/RoboCup-SSL/${repo}/releases/download/${version}/${binary_name}" --output "${binary_path}"
    chmod +x "${binary_path}"
    rm -f "${target_folder}/${app}"
    (cd "${target_folder}" && ln -s "${binary_name}" "${app}")
  fi
}

function uninstall_app() {
  local -r app="$1"

  echo "Uninstall app ${app}"
  uninstall_systemd "${app}"
  rm -f "${target_folder}/${app}"
  rm -f "${target_folder}/${app}_"*
}

function install_systemd() {
  local -r app="$1"

  install_app "${app}"
  echo "Installing systemd service for ${app}"
  if [[ -f "${SCRIPT_DIR}/systemd/${app}.service" ]]; then
    if ! systemctl --user | grep "${app}.service" >/dev/null; then
      mkdir -p "${systemd_folder}"
      cp "${SCRIPT_DIR}/systemd/${app}.service" "${systemd_folder}"
      mkdir -p "${config_folder}/${app}"
      systemctl --user enable "${app}.service"
      systemctl --user daemon-reload
    fi
    echo "Restarting app for ${app}"
    systemctl --user restart "${app}.service"
  else
    echo "No systemd service file found for $app" >&2
    exit 1
  fi
}

function uninstall_systemd() {
  local -r app="$1"

  echo "Uninstall systemd service for ${app}"
  if systemctl --user | grep "${app}.service" >/dev/null; then
    systemctl --user stop "${app}.service"
    systemctl --user disable "${app}.service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
    rm -f "${systemd_folder}/${app}.service"
  fi
}

case $action in

status)
  systemctl --user status "${systemd_services[@]}"
  ;;

start)
  systemctl --user start "${systemd_services[@]}"
  ;;

stop)
  systemctl --user stop "${systemd_services[@]}"
  ;;

restart)
  systemctl --user restart "${systemd_services[@]}"
  ;;

logs)
  parameters=()
  for unit in "${systemd_services[@]}"; do
    parameters+=("-u")
    parameters+=("${unit}")
  done
  journalctl -r --user "${parameters[@]}"
  ;;

install_apps)
  for a in "${apps[@]}"; do
    install_app "${a}"
  done
  ;;

uninstall_apps)
  for a in "${apps[@]}"; do
    uninstall_app "${a}"
  done
  ;;

install_systemd)
  for a in "${systemd_services[@]}"; do
    install_systemd "${a}"
  done
  ;;

uninstall_systemd)
  for a in "${systemd_services[@]}"; do
    uninstall_systemd "${a}"
  done
  ;;

*)
  echo "Invalid action. Valid actions are:"
  echo "  install_apps uninstall_apps"
  echo "  install_systemd uninstall_systemd"
  echo "  status start stop restart"
  echo "  logs"
  ;;
esac
