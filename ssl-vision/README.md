# SSL-Vision Setup
The Small Size Leagues uses Blackfly S (BFS-U3-51S5C-C) USB3 cameras for [ssl-vision](https://github.com/RoboCup-SSL/ssl-vision).
Due to cable length restrictions, the cameras are connected to an Intel NUC (NUC7i7BNH) that is mounted next to the camera.
Users connect to this computer with VNC from another computer next to the field.

The scripts set up such a computer.

## Preparation
The scripts assume a *Xubuntu 22.04* installation.
During installation, select the *Minimal Installation* and the following user settings:

* Username: `vision`
* Hostname: `ssl-vision-X` (as labeled on the NUC)
* Automatic Login: Yes

## Execution
The scripts are idempotent, you can run them multiple times. Some depend on each other.
To configure everything in the correct order, run:

```shell
./configure.sh
```

There is some interaction required.