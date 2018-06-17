#!/bin/bash

terminator -e "cd ~/git/ssl-refbox && ./sslrefbox; read" &
terminator -e "ssl-status-board-server; read" &
terminator -e "~/git/ssl-logtools/build/bin/logrecorder; read" &
