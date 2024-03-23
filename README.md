# ARM-rstudio-server
~~Build~~ Install binaries for rstudio-server on an aarch64 Android device.

## Tested Ubuntu installations
This script has been used to successfully build RStudio Server on the Poco F5 (aarch64) running Ubuntu jammy via chroot or proot using [Moe-hacker/termux-container](https://github.com/Moe-hacker/termux-container). If Termux doesn't work you can use [termux/proot-distro](https://github.com/termux/proot-distro).
Chroot runs linux commands natively so it is faster than proot but it requires root. That is, if you have a rooted Android device, you should use chroot.

## Setup Termux
Download [termux from the F-Droid store](https://f-droid.org/en/packages/com.termux/) open termux and run the following
```
termux-setup-storage
termux-wake-lock
pkg update && pkg upgrade # Answer y to update repos and packages
pkg install git
```

To avoid CPU going into sleep mode, making the installation and rstudio slow if the screen turns off, we used ```termux-wake-lock```
Alternatively, press the button AQCUIRE WAKELOCK from the notifications panel.
You should also active wake lock before starting an RStudio session to avoid a lagging experience.

### Install termux-container

#### For rooted devices
Make sure termux has root privileges before installing termux-container to avoid bugs
Run ```su``` then exit root running ```exit```

Install [Moe-hacker/termux-container](https://github.com/Moe-hacker/termux-container) currently we have to use v8.0 of termux-container, use this code:
1. Install termux-container
```
git clone -b v8.0 https://github.com/Moe-hacker/termux-container
cd termux-container/package
chmod -R 755 DEBIAN
chmod 777 data/data/com.termux/files/usr/bin/container
dpkg -b . ~/termux-container.deb
apt update
apt install ~/termux-container.deb
```
2. Run ```container``` and install ubuntu by runing the ```new``` command, then set parameters for the container like the name (used to access it later). For type choose chroot(or proot if you do not have root), mount sdcard (to see your phone files), absolute path you can use ```/data/ubuntu``` (or ```/data/data/com.termux/files/home/ubuntu``` for non rooted users), for image path you can use  ```/data/ubuntuim``` (or ```/data/data/com.termux/files/home/ubuntuim``` for non rooted users), for OS type ```ubuntu``` version ```jammy```. The automatic option to download the rootfs (ubuntu image) is broken so manually enter the link to download the ubuntu image ```https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/jammy/arm64/default/20240323_08%3A12/rootfs.tar.xz``` or get latest release by going to ```https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/jammy/``` and search for latest file rootfs.tar.xz
3. To start ubuntu run ```container``` and select run container.

Install [termux/proot-distro](https://github.com/termux/proot-distro)
```
pkg install proot-distro
proot-distro install ubuntu
echo "proot-distro login ubuntu --isolated --bind /sdcard:/sdcard" >$PREFIX/bin/prubuntu
chmod +x $PREFIX/bin/prubuntu
prubuntu
```
Use "prubuntu" command to start ubuntu

## Install R and RStudio binaries
In Ubuntu run the commands below
```
# Update and upgrade the system packages and install necessary packages
apt update && apt upgrade -y
apt install -y sudo curl wget gdebi-core r-base

# Fetch the latest RStudio Server download link from the webpage
DOWNLOAD_URL=$(curl -s https://dailies.rstudio.com/rstudio/chocolate-cosmos/server/jammy-arm64/ | grep -oP 'href="\K(https://s3.amazonaws.com/rstudio-ide-build/server/jammy/arm64/rstudio-server-[0-9]+\.[0-9]+\.[0-9]+-[0-9]+-arm64\.deb)' | head -1)

# Extract the version number from the URL for later installation
VERS=$(echo $DOWNLOAD_URL | grep -oP 'rstudio-server-\K[0-9]+\.[0-9]+\.[0-9]+-[0-9]+(?=-arm64\.deb)')

# Download the RStudio Server package
wget $DOWNLOAD_URL

# Install the downloaded package
sudo gdebi -n rstudio-server-${VERS}-arm64.deb
```

This script scrapes the latest build of rstudio server available. The `VERS` variable in the script can be updated to build different versions of the server. The latest version number can be found on [download page](https://dailies.rstudio.com/), and clicking on the arm64 link in the RStudio Server Ubuntu 22 section.

#### Non-rooted devices fix
For non-rooted devices you have to login as the root user of the ubuntu environment. To do so run:
```
sudo mkdir -p /etc/rstudio/
sudo touch /etc/rstudio/rserver.conf
sudo echo "auth-minimum-user-id=0" > /etc/rstudio/rserver.conf
# Set password for root
sudo passwd root
# Access phone files from RStudio
ln -s /sdcard "${HOME}/sdcard"
sudo rstudio-server restart
```

### Rooted devices login
For rooted devices you can login as root using the code above or create a new user and login with those credentials using the following code:
```
read -p "Add new user to login from RStudio? [yn]" answer
if [[ $answer = y ]] ; then
  read -p "Insert user name:" user
  sudo useradd -s /bin/bash -m -G sudo $user
  echo "$user  ALL=(ALL) ALL" | sudo tee -a /etc/sudoers > /dev/null
  echo Insert password for $user
  sudo passwd $user
  ## Fix internet access for new user created (issue seen in chrooted ubuntu - termux-container from Moe-hacker)
  inetGroupName=$(cat /etc/group | grep 3003 | cut -d: -f1)
  sudo usermod -a -G $inetGroupName $user
  # Access phone files from RStudio
  ln -s /sdcard /home/${user}/sdcard
fi
```

## Launching RStudio Server
After the server has been built and installed, the easiest way to start the server from a crosh shell using the commands below
```
sudo rstudio-server start
ipv4=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo Open internet browser and go to localhost:8787 or if you want to login from another device of the same network go to $ipv4:8787
```
Finally, from a new Chrome tab navigate to `localhost:8787` (from your phone only) or from `your.phone's.ip.address:8787` (example `192.168.1.2:8787`) and log in with the users you set.

## Stopping RStudio Server
just run:
```
sudo rstudio-server stop
```
