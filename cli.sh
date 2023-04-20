#!/usr/bin/env bash
set -euo pipefail

# determine current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

readonly goos="linux"
readonly goarch="amd64"
readonly binary_folder="$HOME/.local/bin"
readonly config_folder="$HOME/.config"
readonly systemd_folder="$HOME/.local/share/systemd/user"
readonly autoref_folder="$HOME/.local/share/auto-referees"
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
  local -r org="$1"
  local -r repo="$2"
  curl -s "https://api.github.com/repos/${org}/${repo}/releases/latest" | jq -r '.tag_name'
}

function install_app() {
  local -r app="$1"
  local repo="${app_repo_map[${app}]}"
  local version
  version="$(latest_version "RoboCup-SSL" "${repo}")"
  echo "Latest version of ${app} from ${repo} is ${version}"
  local binary_name="${app}_${version}_${goos}_${goarch}"
  local binary_path="${binary_folder}/${binary_name}"
  if [[ ! -f "${binary_path}" ]]; then
    echo "Downloading ${binary_name}"
    mkdir -p "${binary_folder}"
    curl --location --fail --silent "https://github.com/RoboCup-SSL/${repo}/releases/download/${version}/${binary_name}" --output "${binary_path}"
    chmod +x "${binary_path}"
    rm -f "${binary_folder}/${app}"
    (cd "${binary_folder}" && ln -s "${binary_name}" "${app}")
  fi
}

function uninstall_app() {
  local -r app="$1"

  echo "Uninstall app ${app}"
  uninstall_systemd "${app}"
  rm -f "${binary_folder}/${app}"
  rm -f "${binary_folder}/${app}_"*
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

function install_autoref_tigers() {
  local -r repo="AutoReferee"
  local version
  version_tag="$(latest_version "TIGERs-Mannheim" "${repo}")"
  version="${version_tag#version/*}"
  echo "Latest version of ${repo} is ${version}"
set -x
  mkdir -p "${autoref_folder}"
  local archive_name="autoReferee.zip"
  local archive_path="${autoref_folder}/autoReferee-${version}.zip"

  if [[ ! -f "${archive_path}" ]]; then
    echo "Downloading ${archive_name}"
    mkdir -p "${autoref_folder}"
    curl --location --fail --silent "https://github.com/TIGERs-Mannheim/${repo}/releases/download/${version_tag}/${archive_name}" --output "${archive_path}"
    echo "Unzipping ${archive_path}"
    unzip "${archive_path}" -d "${autoref_folder}"
    mv "${autoref_folder}/autoReferee" "${autoref_folder}/autoReferee-${version}"
    (cd "${autoref_folder}" && ln -s "autoReferee-${version}" "autoReferee")
    cat << EOF > "${binary_folder}/auto-referee-tigers"
#!/usr/bin/env bash
cd "${autoref_folder}/autoReferee"
bin/autoReferee "\$@"
EOF
    chmod +x "${binary_folder}/auto-referee-tigers"
  fi
}

function uninstall_autoref_tigers() {
  rm -rf "${autoref_folder}/autoReferee"*
}

function configure_system() {
  sudo apt update
  sudo apt upgrade -y
  which snap >/dev/null && sudo snap refresh
  sudo apt install -y git neovim curl terminator remmina openjdk-17-jre

  echo "Disable screensaver"
  which gsettings >/dev/null && gsettings set org.gnome.desktop.screensaver lock-enabled false
}

case $action in

apps)
  echo "Available apps: ${apps[*]}"
  ;;

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

configure_system)
  configure_system
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

install_autoref_tigers)
  install_autoref_tigers
  ;;

uninstall_autoref_tigers)
  uninstall_autoref_tigers
  ;;

*)
  echo "Invalid action. Valid actions are:"
  echo "  install_apps uninstall_apps"
  echo "  install_systemd uninstall_systemd"
  echo "  status start stop restart"
  echo "  logs"
  ;;
esac
