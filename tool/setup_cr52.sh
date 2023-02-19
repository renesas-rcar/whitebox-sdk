#!/bin/bash

sudo apt install python3-venv -y

wget -c https://apt.kitware.com/kitware-archive.sh
sudo bash kitware-archive.sh

sudo apt install --no-install-recommends git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 -y

