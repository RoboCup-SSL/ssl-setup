#!/bin/bash

set -eu

systemctl --user stop ssl-game-controller.service
BINARY_URL=$(curl -SsL https://github.com/RoboCup-SSL/ssl-game-controller/releases/latest \
		 | grep 'ssl-game-controller_v.*_linux_amd64' \
		 | awk '{$1=$1;print}' \
                 | cut -d = -f 2 \
                 | cut -d '"' -f 2 \
                 | head -n 1 \
                 | xargs printf "https://github.com/%s")

curl -sSL $BINARY_URL > ~/.local/bin/ssl-game-controller
chmod +x ~/.local/bin/ssl-game-controller
systemctl --user start ssl-game-controller.service
