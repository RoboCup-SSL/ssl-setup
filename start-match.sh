#!/bin/bash

terminator -e "cd ~/git/ssl-refbox && ./sslrefbox; read" &
terminator -e "~/go/bin/ssl-status-board-server; read" &
terminator -e "mkdir -p ~/logs; ~/git/ssl-logtools/build/bin/logrecorder --compress --output ~/logs/`date +%Y-%m-%d_%H-%M-%S.log.gz`; read" &
