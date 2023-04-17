#!/usr/bin/env bash
set -euo pipefail

readonly target_folder="$HOME/.local/bin"
readonly systemd_folder="$HOME/.local/share/systemd/user"

function remove_app() {
  local -r app="$1"

  if systemctl --user | grep "${app}.service" >/dev/null; then
    echo "Removing service for app ${app}"
    systemctl --user stop "${app}.service"
    systemctl --user disable "${app}.service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
    rm -f "${systemd_folder}/${app}.service"
  fi

  rm -f "${target_folder}/${app}"
  rm -f "${target_folder}/${app}_"*
}

remove_app ssl-game-controller
remove_app ssl-ref-client
remove_app ssl-auto-recorder
remove_app ssl-vision-client
remove_app ssl-vision-cli
