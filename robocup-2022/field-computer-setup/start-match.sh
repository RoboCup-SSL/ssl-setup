#!/bin/bash

terminator -e "cd ~/ssl-autorefs && ./run_tigers.sh -a; read" &
terminator -e "cd ~/ssl-autorefs && ./run_erforce.sh; read" &
