#!/bin/bash

sudo apt update
sudo apt install gawk chrpath diffstat curl bzip2 pipx python3-pip -y
export PATH=~/.local/bin:$PATH
pipx install git+https://github.com/xen-troops/moulin
sudo apt install ninja-build

# For Ubuntu 24.04
UBUNTU_VERSION=$( cat /etc/os-release | grep VERSION_ID | cut -d'"' -f2)
if [[ "${UBUNTU_VERSION}" == "24.04" ]]; then
    sudo apt install python3-pyasyncore -y
fi

