# ARM-rstudio-server
Build script for rstudio-server on an aarch64 Android device

This is built on the excellent work of [dashaub/ARM-RStudio](https://github.com/dashaub/ARM-RStudio) and [jrowen/ARM-rstudio-server](https://github.com/jrowen/ARM-rstudio-server).

## Tested Ubuntu installations
This script has been used to successfully build RStudio Server on the Poco F3 (aarch64) running Ubuntu 20.04 via [chroot](https://github.com/Moe-hacker/termux-container), ([using this image](http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/)), or Ubuntu 22.04 via [proot](https://github.com/MFDGaming/ubuntu-in-termux) (image in script). Chroot runs linux commands natively so it is faster than proot but it requires root. That is, if you have a rooted Android device, you should use chroot. The script does not work in ubuntu installed from [Andronix](https://github.com/AndronixApp/AndronixOrigin) since it uses an old Ubuntu image with symlink issues on some libraries required for building.

## Build
In Ubuntu run the command below to build the server
```
git clone https://github.com/Fr4nzz/ARM-rstudio-server
bash ARM-rstudio-server/build_rstudio.sh
```
The build may take several hours to complete, it's recommended to keep the device with the screen turned on for faster compilation.

The `VERS` variable in the script can be updated to build different versions of the server.  The latest version number and be found on the rstudio server [download page](https://www.rstudio.com/products/rstudio/download-server/), and note that this will likely differ from the latest desktop version.

## Launching RStudio Server
After the server has been built and installed, the easiest way to start the server from a crosh shell using the commands below
```
sudo rstudio-server start
```
Finally, from a new Chrome tab navigate to `localhost:8787` and log in using your chroot credentials.
