# SSL-Vision Setup
The Small Size Leagues uses Blackfly S (BFS-U3-51S5C-C) USB3 cameras for [ssl-vision](https://github.com/RoboCup-SSL/ssl-vision).
Due to cable length restrictions, the cameras are connected to an Intel NUC (NUC7i7BNH) that is mounted next to the camera.
Users connect to this computer with VNC from another computer next to the field.

The scripts set up such a computer.

## Preparation
The scripts assume a *Xubuntu 24.04* installation.
During installation, select the *Minimal Installation* and the following user settings:

* Username: `vision`
* Hostname: `ssl-vision-x` (as labeled on the NUC)
* Require my password to login: No
* Automatic Login: Yes

## Execution
The scripts are idempotent, you can run them multiple times. Some depend on each other.
To configure everything in the correct order, run:

```shell
./configure.sh
```

There is some interaction required.

### Vision Processor 

To setup a nuc with [vision-processor](https://github.com/TIGERs-Mannheim/vision-processor) instead, run:
```shell
./configure.sh vp
```


## Configure chrony for multiple camera setups
If there is more than one camera for one field, like in division A, the clocks of all computers, that are running ssl-vision, have to be synchronized.
The scripts install chrony, an NTP server implementation and interactively ask for the server IP. You can run the script again for reconfiguration:

```shell
./configure-chrony.sh
```

Afterward, it may take some time until the client as synchronized. Here are some useful commands:

```shell
# Make a step (instead of slewing) - requires some measurements, so you may need to wait a bit before running it
chronyc -a makestep

# List sources (should only be one)
chronyc sources

# Show tracking offset
chronyc tracking
```

## Optional: Update firmware of the camera
The camera firmware can be updated with the following CLI tool, included in the Spinnaker SDK:

```shell
SpinUpdateConsole '-R.*' BFS-U3-51S5-Package/BFS-U3-51S5_1801.0.1.0.ez2
```

The latest firmware can be found here: https://www.flir.com/support/products/blackfly-s-usb3/?vertical=machine+vision&segment=iis#Downloads
