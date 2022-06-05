#!/usr/bin/env bash
#This script installs R and builds RStudio Server for aarch64 Android running Ubuntu 20.04

set -euo pipefail

#Set RStudio version
VERS='v2022.02.3+492'
BUILD_DIR="${HOME}"

echo "Installing sudo"
if ! [ -x "$(command -v sudo)" ]; then
  apt update
  apt -y install sudo
fi

#Install R
echo "Installing R"
if ! [ -x "$(command -v R)" ]; then
  sudo apt-get -y  install apt-transport-https software-properties-common
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
  sudo add-apt-repository -y 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
  sudo apt update
  sudo apt-get -y install r-base r-base-dev
fi

#Install RStudio build dependencies
echo "Installing system packages"
sudo apt-get install -y git pandoc ghc cabal-install wget
sudo apt-get install -y build-essential pkg-config fakeroot cmake ant apparmor-utils clang debsigs dpkg-sig expect gnupg1
sudo apt-get install -y uuid-dev libssl-dev libbz2-dev zlib1g-dev libpam-dev libacl1-dev libyaml-cpp-dev
sudo apt-get install -y libapparmor1 libboost-all-dev libpango1.0-dev libjpeg62 libattr1-dev libcap-dev libclang-dev
sudo apt-get install -y libcurl4-openssl-dev libegl1-mesa libfuse2 libgl1-mesa-dev libgtk-3-0 libssl-dev libuser1-dev libxslt1-dev
sudo apt-get install -y lsof patchelf rrdtool software-properties-common libpq-dev libsqlite3-dev

#Install Python
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.9

#Installing JAVA
# Java 8 (not in official repo for bionic)
echo "Installing Java"
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get -y install openjdk-8-jdk
sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-arm64/jre/bin/java

#Download RStudio source

echo "Downloading RStudio ${VERS}"
cd "${BUILD_DIR}"
wget -nc "https://github.com/rstudio/rstudio/archive/refs/tags/${VERS}.tar.gz"
mkdir -p "rstudio-${VERS}"
tar xvf "${VERS}.tar.gz" -C "rstudio-${VERS}" --strip-components 1

#Run common environment preparation scripts
cd "${BUILD_DIR}/rstudio-${VERS}/dependencies/common/"
mkdir -p "${BUILD_DIR}/rstudio-${VERS}/dependencies/common/pandoc"
cd "${BUILD_DIR}/rstudio-${VERS}/dependencies/common/"
#Workaround so that cmake could find boost libraries when installing soci in ubuntu from Andronix
#sudo ln -s /usr/include /include
echo "Installing dependencies"
./install-common
#Workaround cmake could not find ant in ubuntu from Andronix
#ln -snf /usr/share/ant/bin/ant /bin/ant

#Configure cmake and build RStudio
echo "Building RStudio"
cd "${BUILD_DIR}/rstudio-${VERS}/"
mkdir -p build
CXXFLAGS="-march=native" cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release
echo "Installing RStudio"
sudo make install

# Additional install steps
sudo useradd -r rstudio-server
## Fix internet access for new user created (issue seen in chrooted ubuntu - termux-container from Moe-hacker)
inetGroupName=$(cat /etc/group | grep 999 | cut -d: -f1)
usermod -a -G $inetGroupName rstudio-server
## End of fix
sudo cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server
sudo chmod +x /etc/init.d/rstudio-server 
sudo ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server
sudo chmod 777 -R /usr/local/lib/R/site-library/

# Setup locale
sudo apt-get install -y locales
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#Clean the system of packages used for building
echo "Removing installed packages"
sudo apt-get autoremove -y cabal-install ghc pandoc libboost-all-dev
sudo rm -rf "${BUILD_DIR}/rstudio-${VERS}"
rm "${BUILD_DIR}/${VERS}.tar.gz"
sudo apt-get autoremove -y

# Start the server
sudo rstudio-server start
echo Open internet browser and go to localhost:8787
