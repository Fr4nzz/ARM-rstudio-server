# ARM-rstudio-server
Build script for rstudio-server on an aarch64 Android device

This is built on the excellent work of [dashaub/ARM-RStudio](https://github.com/dashaub/ARM-RStudio) and [jrowen/ARM-rstudio-server](https://github.com/jrowen/ARM-rstudio-server).

## Tested Ubuntu installations
This script has been used to successfully build RStudio Server on the Poco F3 (aarch64) running Ubuntu 20.04 via chroot using [Moe-hacker/termux-container](https://github.com/Moe-hacker/termux-container), (using the latest arm64 image from [here](http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/)), or Ubuntu 22.04 via proot using [termux/proot-distro](https://github.com/termux/proot-distro).
Chroot runs linux commands natively so it is faster than proot but it requires root. That is, if you have a rooted Android device, you should use chroot.
The script does not work in ubuntu installed from [Andronix](https://github.com/AndronixApp/AndronixOrigin) since it uses an old Ubuntu image with symlink issues on some libraries required for building.

## Setup Ubuntu
Download [termux from the F-Droid store](https://f-droid.org/en/packages/com.termux/) open termux and run the following
```
termux-setup-storage
apt update && apt upgrade # Answer y to update repos and packages
```
### Rooted android devices
Install [Moe-hacker/termux-container](https://github.com/Moe-hacker/termux-container) following its instructions

### Non rooted android devices
Run the following to install ubuntu using [termux/proot-distro](https://github.com/termux/proot-distro)
```
pkg install proot-distro
proot-distro install ubuntu
echo "proot-distro login ubuntu --isolated --bind /sdcard:/sdcard" >$PREFIX/bin/prubuntu
chmod +x $PREFIX/bin/prubuntu
prubuntu
```
Use "prubuntu" command to start ubuntu

## Build
In Ubuntu run the commands below to build the server
```
wget https://raw.githubusercontent.com/Fr4nzz/ARM-rstudio-server/master/build_rstudio.sh
bash build_rstudio.sh
```
The build may take several hours to complete, it's recommended to set the screen timeout to infinite to avoid cpu undervolting (longer compilation time).

The `VERS` variable in the script can be updated to build different versions of the server.  The latest version number can be found on the rstudio server [download page](https://www.rstudio.com/products/rstudio/download-server/), and note that this will likely differ from the latest desktop version.

## Launching RStudio Server
After the server has been built and installed, the easiest way to start the server from a crosh shell using the commands below
```
sudo rstudio-server start
```
Finally, from a new Chrome tab navigate to `localhost:8787` and log in using your chroot credentials.
