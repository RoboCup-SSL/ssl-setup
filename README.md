# SSL Setup
Collection of scripts that set up computers for a tournament.

## Preparation
A tournament requires at least one field.
Each field requires one or more computers.
For an official RoboCup, the following computers must be set up:

* Vision
* Vision-Expert
* Game-Controller

The computers should run a recent Ubuntu LTS version or one of it flavors.

For details, check the rules: https://robocup-ssl.github.io/ssl-rules/sslrules.html#_shared_software

## Execution
### Vision
see [ssl-vision](./ssl-vision/README.md)

### Vision-Expert
Run at least:

```shell
./cli.sh install_apps
./cli.sh install_systemd ssl-vision-client
```

### Game-Controller
Install all:

```shell
./cli.sh install_apps
./cli.sh install_systemd
```
