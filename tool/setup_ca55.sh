#!/bin/bash

sudo apt install python3-pip gawk chrpath diffstat curl -y
pip install -U pip
export PATH=~/.local/bin:$PATH
pip install pygit2
pip install --user git+https://github.com/xen-troops/moulin
sudo apt install ninja-build

