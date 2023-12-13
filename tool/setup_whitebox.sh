#!/bin/bash

ZIPNAME=CC-RH_V20500_setup-doc.zip
SCRIPT_DIR=$(cd `dirname $0` && pwd)

print_err() {
    for arr in "$@"; do
        echo -e "\e[31m$arr\e[m"
    done
}

cd $SCRIPT_DIR
if [[ ! $ZIPNAME = /* ]]; then
  ZIPNAME=$(pwd)/$ZIPNAME
fi

if [ ! -e $ZIPNAME ]; then
  print_err "ERROR: $ZIPNAME is not found."
  print_err "    This is used for building G4MH software."
  print_err "    1. Please donwload \"RH850 Compiler CC-RH V2.05.00 for e2 studio\" from following:"
  print_err "    https://www.renesas.com/us/en/software-tool/c-compiler-package-rh850-family#download"
  print_err "    2. Then, copy it into this directory"
  print_err "    cp <path to CC-RH_V20500_setup-doc.zip> ,/"
  exit
fi

./setup_wine.sh
./setup_csp.sh $ZIPNAME
./setup_ca55.sh
./setup_cr52.sh
./setup_safeg.sh

