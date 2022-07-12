#!/bin/bash

terminator -e "cd ~/git/ssl-refbox && ./sslrefbox; read" &
terminator -e "~/go/bin/ssl-status-board-server -c ~/server-config.yaml; read" &
#terminator -e "mkdir -p ~/logs; ~/git/ssl-logtools/build/bin/logrecorder --compress --output ~/logs/`date +%Y-%m-%d_%H-%M-%S.log.gz`; read" &
terminator -e "mkdir -p ~/logs; ~/go/bin/ssl-recorder; read" &
terminator -e "cd ~/git/ssl-autorefs && ./run_tigers.sh -a; read" &
terminator -e "cd ~/git/ssl-autorefs && ./run_erforce.sh; read" &
