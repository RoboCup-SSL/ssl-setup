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
There are two ways to run all the software on the Game-Controller computer.
You can install the software natively, or you can run it with Docker.
You can also mix it.

#### Native Installation

```shell
# Configure Ubuntu
./cli.sh configure_system
# Install all apps
./cli.sh install_apps
# Install all systemd services
./cli.sh install_systemd
# Install autorefs
./cli.sh install_autorefs
```

#### Docker-Compose
Pull all required docker images:

```shell
docker compose pull
```

Start only the basic tools without auto-referees:
```shell
docker compose up
```

You can run the auto-referees with their UI.
This will only work on a Linux PC with an XOrg Server:

```shell
docker compose --profile autorefs-ui up 
```

Or you run the auto-referees in headless mode:

```shell
docker compose --profile autorefs-headless up
```


### Status-Board
See: https://github.com/RoboCup-SSL/ssl-status-board/blob/master/rpi/Readme.md

### Remote-Control
See: https://github.com/RoboCup-SSL/ssl-remote-control/blob/master/rpi/Readme.md

## Monitoring and Troubleshooting
The following commands are available for the natively installed apps:

```shell
# List available apps
./cli.sh apps

# Start/Stop/Restart single or all apps
./cli.sh start|stop|restart [app]

# See logs of systemd services
./cli.sh logs [app]
```

## Known Issues: 

### GC Not Responding

If the GC (Game Controller) is unresponsive to any event, try deleting the state file. This issue may occur if the GC has been active for an extended period and has recognized too many events.

**Caution:** Deleting the state file will erase the current game state for the GC.

```shell

./cli.sh stop # stop apps

cd ~/.config/ssl-game-controller/config
rm state-store.json.stream # delete bad state stream

./cli.sh restart # restart apps

```
