#!/bin/bash

WB_VER=v5.1

echo Install git client # Include a process to skip if the environment is already in.
if [[ $(git --version > /dev/null 2>&1 ; echo $?) -ne 0 ]]; then
    echo sudo apt install git
    sudo apt install git
else
    echo "--> Skipped because git clinet is already installed."
fi
echo ------ # splitter

echo "Setup git config(Add username and email)"
if [[ "$(git config --global --list | grep user)" == "" ]]; then
    git config --global user.name "Dummy"
    git config --global user.email "dummy@example.com"
else
    echo "--> Skipped because user infomation is already setup."
    git config --global --list | grep user
fi
echo ------ # splitter

echo Download whitebox SDK repository
if [[ ! -d ./whitebox-sdk ]] ;then
    git clone https://github.com/renesas-rcar/whitebox-sdk.git -b ${WB_VER}
else
    echo "--> whitebox-sdk is already downloaded."
    echo "    Try to download latest version if possible."
    cd whitebox-sdk
    echo -n "    " && git fetch && git reset --hard ${WB_VER}
    cd ../
fi

echo "+------------------+"
echo "|  Setup is done!  |"
echo "+------------------+"

