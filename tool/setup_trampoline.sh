#!/bin/bash

BINPATH=~/.local/bin
mkdir -p ${BINPATH}

# Goil
wget -c http://trampolinebin.rts-software.org/goil-linux-64.zip
unzip -qo goil-linux-64.zip
mv goil goil-debug -t ${BINPATH}
rm -rf goil-linux-64.zip

echo "Completed."

