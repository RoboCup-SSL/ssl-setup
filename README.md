# SSL Setup
Collection of scripts that set up computers for a tournament.

## Preparation
A tournament requires at least one field.
Each field requires one or more computers.
For an official RoboCup, the following computers must be set up:

* 1-2x Vision
* 1x Vision-Expert
* 1x Game-Controller
* 1-2x Status-Board (RaspberryPi)
* 2x Remote-Control (RaspberryPi)

The computers should run a recent Ubuntu LTS version or one of it flavors.

For details, check the rules: https://robocup-ssl.github.io/ssl-rules/sslrules.html#_shared_software

## Execution
### Vision
see [ssl-vision](./ssl-vision/README.md)

### Vision-Expert
Run at least:

```shell
# Configure Ubuntu
./cli.sh configure_system
# Install all apps
./cli.sh install_apps
# Install systemd service for vision-client
./cli.sh install_systemd ssl-vision-client
```

### Game-Controller
Install all:

```shell
# Configure Ubuntu
./cli.sh configure_system
# Install all apps
./cli.sh install_apps
# Install all systemd services
./cli.sh install_systemd
```

### Status-Board
See: https://github.com/RoboCup-SSL/ssl-status-board/blob/master/rpi/Readme.md

### Remote-Control
See: https://github.com/RoboCup-SSL/ssl-remote-control/blob/master/rpi/Readme.md

## Monitoring and Troubleshooting
The following commands are available:

```shell
# List available apps
./cli.sh apps

# Start/Stop/Restart single or all apps
./cli.sh start|stop|restart [app]

# See logs of systemd services
./cli.sh logs [app]
```
