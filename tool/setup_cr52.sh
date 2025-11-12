#!/bin/bash

sudo apt update
sudo apt install python3-venv -y

wget -c https://apt.kitware.com/kitware-archive.sh
sudo bash kitware-archive.sh

sudo apt install --no-install-recommends --allow-downgrades \
  git cmake=3.* cmake-data=3.* ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc libsdl2-dev libmagic1 -y

