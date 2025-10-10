#!/bin/bash

sudo apt update
sudo apt install gawk chrpath diffstat curl bzip2 pipx python3-pip -y
export PATH=~/.local/bin:$PATH
pipx install git+https://github.com/xen-troops/moulin
sudo apt install ninja-build

