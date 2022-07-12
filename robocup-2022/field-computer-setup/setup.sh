#!/bin/bash
set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $HOME

sudo apt update && sudo apt upgrade -y

sudo apt install -y figlet toilet

figlet "Disable screensaver"
gsettings set org.gnome.desktop.screensaver lock-enabled false

figlet "Installing apt packages"

sudo apt install -y git cmake build-essential tmux emacs vim curl terminator

figlet "Go"
sudo apt update
sudo snap install go --classic

GOPATH_BASHRC='export GOPATH=$HOME/go'
if ! grep -Fxq "$GOPATH_BASHRC" ~/.bashrc; then
    echo "$GOPATH_BASHRC" >> ~/.bashrc
fi
GO_BIN_BASHRC='export PATH=$GOPATH/bin:$PATH'
if ! grep -Fxq "$GO_BIN_BASHRC" ~/.bashrc; then
    echo "$GO_BIN_BASHRC" >> ~/.bashrc
fi
GO_BASHRC='export PATH=/usr/lib/go-1.11/bin:$PATH'
if ! grep -Fxq "$GO_BASHRC" ~/.bashrc; then
    echo "$GO_BASHRC" >> ~/.bashrc
fi

eval "$GOPATH_BASHRC"
eval "$GO_BIN_BASHRC"
eval "$GO_BASHRC"


figlet "Nodejs"
#curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install -y nodejs

figlet "SSL Log Tools"
go install github.com/RoboCup-SSL/ssl-go-tools/...@latest
figlet "SSL Vision Client"

go install github.com/RoboCup-SSL/ssl-vision-client/...@latest
pushd $GOPATH/go/pkg/mod/github.com/!robo!cup-!s!s!l/ssl-vision-client
go build cmd/ssl-vision-client/main.go
sudo apt install npm -y
npm install
npm run build

go install github.com/gobuffalo/packr/packr@latest
cd cmd/ssl-vision-client
packr install
popd

figlet "SSL Game Controller"
LOCAL_BIN_BASHRC='export PATH=~/.local/bin:$PATH'
if ! grep -Fxq "$LOCAL_BIN_BASHRC" ~/.bashrc; then
    echo "$LOCAL_BIN_BASHRC" >> ~/.bashrc
fi

mkdir -p ~/.local/bin
curl -sSL https://github.com/RoboCup-SSL/ssl-game-controller/releases/download/v2.16.1/ssl-game-controller_v2.16.1_linux_amd64 > ~/.local/bin/ssl-game-controller
chmod +x ~/.local/bin/ssl-game-controller

figlet "SSL Logtools"

sudo add-apt-repository -y ppa:maarten-fonville/protobuf
sudo apt install -y libqt4-dev libboost-all-dev libboost-program-options-dev protobuf-compiler libprotobuf-dev

if [[ ! -d ~/ssl-logtools ]]; then
    git clone https://github.com/RoboCup-SSL/ssl-logtools.git
fi
pushd ~/ssl-logtools
mkdir -p build
cd build
cmake ..
make -j
mv bin/* ~/.local/bin/
popd

figlet "SSL Autorefs"

sudo apt install -y libeigen3-dev libjemalloc-dev

if [[ ! -d ~/ssl-autorefs ]]; then
    git clone --recursive -b robocup2022 https://github.com/RoboCup-SSL/ssl-autorefs.git
fi
pushd ~/ssl-autorefs
sudo ./installDeps.sh
./buildAll.sh
popd

figlet "Install systemd services"
mkdir -p ~/.local/share/systemd/user

if [[ ! -f ~/.local/share/systemd/user/ssl-game-controller.service ]]; then
    read -p "Do you want to start ssl-game-controller at startup? (y/N) " choice
    case "$choice" in
	y|Y )     cp $SCRIPT_DIR/ssl-game-controller-boot.service ~/.local/share/systemd/user/ssl-game-controller.service
		  systemctl --user daemon-reload
		  systemctl --user enable ssl-game-controller.service;;
        * )     cp $SCRIPT_DIR/ssl-game-controller.service ~/.local/share/systemd/user/ssl-game-controller.service
		systemctl --user daemon-reload;;
    esac
fi

if [[ ! -f ~/.local/share/systemd/user/ssl-vision-client.service ]]; then
    read -p "Do you want to start ssl-vision-client at startup? (y/N) " choice
    case "$choice" in
	y|Y ) cp $SCRIPT_DIR/ssl-vision-client-boot.service ~/.local/share/systemd/user/ssl-vision-client.service
	      systemctl --user daemon-reload
	      systemctl --user enable ssl-vision-client.service;;
	* ) cp $SCRIPT_DIR/ssl-vision-client.service ~/.local/share/systemd/user/ssl-vision-client.service
	    systemctl --user daemon-reload;;
    esac
fi

cp $SCRIPT_DIR/start-match.sh ~/.local/bin/start-match
chmod +x ~/.local/bin/start-match
cp $SCRIPT_DIR/icon.png ~/.local/share/start-match-icon.png
cp $SCRIPT_DIR/start-match.desktop ~/Desktop/
