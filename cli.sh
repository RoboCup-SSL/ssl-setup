#!/usr/bin/env bash
set -euo pipefail

readonly systemd_services=(ssl-game-controller ssl-auto-recorder)
readonly action=${1:-}

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
  for unit in "${systemd_services[@]}"; do parameters+=("-u"); parameters+=("${unit}"); done
  journalctl -r --user "${parameters[@]}"
  ;;

*)
  echo "Invalid action. Valid actions are: status start stop restart logs"
  ;;
esac
