#!/bin/bash

terminator -e "mkdir -p ~/logs; cd ~/logs; ~/go/bin/ssl-recorder; read" &
terminator -e "cd ~/ssl-autorefs && ./run_tigers.sh; read" &
terminator -e "cd ~/ssl-autorefs && ./run_erforce.sh; read" &
