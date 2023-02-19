#!/bin/bash 

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [ -e /etc/lsb-release ]; then 
    DISTRIB=$(awk -F= '/^DISTRIB_ID/{print $2}' /etc/lsb-release)
    VERSION=$(awk -F= '/^DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
  fi
fi

sudo dpkg --add-architecture i386

sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

if [ "$VERSION" == "22.10" ]; then
  sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/kinetic/winehq-kinetic.sources
  echo "22.10"
else
  if [ "$VERSION" == "22.04" ]; then
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    echo "22.04"
  else
    if [ "$VERSION" == "20.04" ]; then
      sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
      echo "20.04"
    else
      echo "Error "
      exit -1
    fi
  fi
fi

sudo apt update

sudo apt install --install-recommends winehq-stable -y
winecfg
