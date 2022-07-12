#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$HOME"

sudo apt update && sudo apt upgrade -y
sudo apt install -y figlet toilet

figlet "Disable screensaver"
gsettings set org.gnome.desktop.screensaver lock-enabled false

figlet "Installing apt packages"

sudo apt install -y git cmake build-essential tmux emacs vim curl terminator

figlet "Go"
sudo snap install go --classic

GOPATH_BASHRC='export GOPATH=$HOME/go'
if ! grep -Fxq "$GOPATH_BASHRC" ~/.bashrc; then
  echo "$GOPATH_BASHRC" >>~/.bashrc
fi
GO_BIN_BASHRC='export PATH=$GOPATH/bin:$PATH'
if ! grep -Fxq "$GO_BIN_BASHRC" ~/.bashrc; then
  echo "$GO_BIN_BASHRC" >>~/.bashrc
fi

eval "$GOPATH_BASHRC"
eval "$GO_BIN_BASHRC"

figlet "SSL Log Tools"
go install github.com/RoboCup-SSL/ssl-go-tools/...@latest

figlet "SSL Vision Client"
curl -L -o ~/.local/bin/ssl-vision-client https://github.com/RoboCup-SSL/ssl-vision-client/releases/download/v1.6.0/ssl-vision-client_v1.6.0_linux_amd64

figlet "SSL Game Controller"
LOCAL_BIN_BASHRC='export PATH=~/.local/bin:$PATH'
if ! grep -Fxq "$LOCAL_BIN_BASHRC" ~/.bashrc; then
  echo "$LOCAL_BIN_BASHRC" >>~/.bashrc
fi

mkdir -p ~/.local/bin
curl -sSL https://github.com/RoboCup-SSL/ssl-game-controller/releases/download/v2.16.1/ssl-game-controller_v2.16.1_linux_amd64 >~/.local/bin/ssl-game-controller
chmod +x ~/.local/bin/ssl-game-controller

figlet "SSL Autorefs"

if test ! -d "~/ssl-autorefs"
then
  git clone --recursive -b robocup2022 https://github.com/RoboCup-SSL/ssl-autorefs.git
else
    echo "Already downloaded!"
fi


cd ~/ssl-autorefs
sudo ./installDeps.sh
./buildAll.sh
cd ~/

figlet "Install systemd services"
mkdir -p ~/.local/share/systemd/user

read -r -p "Do you want to start ssl-game-controller at startup? (y/N) " choice
case "$choice" in
y | Y)
  cp "$SCRIPT_DIR/ssl-game-controller.service" ~/.local/share/systemd/user/ssl-game-controller.service
  systemctl --user daemon-reload
  systemctl --user enable ssl-game-controller.service
  systemctl --user start ssl-game-controller.service
  ;;
*)
  cp "$SCRIPT_DIR/ssl-game-controller.service" ~/.local/share/systemd/user/ssl-game-controller.service
  systemctl --user daemon-reload
  ;;
esac

read -r -p "Do you want to start ssl-vision-client at startup? (y/N) " choice
case "$choice" in
y | Y)
  cp "$SCRIPT_DIR/ssl-vision-client.service" ~/.local/share/systemd/user/ssl-vision-client.service
  systemctl --user enable ssl-vision-client.service
  systemctl --user start ssl-vision-client.service
  ;;
*)
  cp "$SCRIPT_DIR/ssl-vision-client.service" ~/.local/share/systemd/user/ssl-vision-client.service
  systemctl --user daemon-reload
  ;;
esac

cp "$SCRIPT_DIR/start-match.sh" ~/.local/bin/start-match
chmod +x ~/.local/bin/start-match
cp "$SCRIPT_DIR/icon.png" ~/.local/share/start-match-icon.png
cp "$SCRIPT_DIR/start-match.desktop" ~/Desktop/
