#!/bin/bash

export LANG=C

TMP_DIR=$(pwd)/tmp

rm -rf ${TMP_DIR}

if [ $# != 1 ]; then
  echo "Usage : setup_csp CSPlus_package_file(zip)"
  exit -1
fi

ZIPNAME=$1

if [[ ! $ZIPNAME = /* ]]; then
  ZIPNAME=$(pwd)/$ZIPNAME
fi

if [ ! -e $ZIPNAME ]; then
  echo "Error : File not found."
  exit -2
fi

sudo apt install p7zip-full -y

FILENAME=${ZIPNAME##*/}
FOLDERNAME=${FILENAME%%.*}
EXENAME=${FOLDERNAME%%-doc-?}

mkdir -p ${TMP_DIR}
cd ${TMP_DIR}

unzip $ZIPNAME
cd $FOLDERNAME
7za x $EXENAME".EXE"

TOOLVER=`echo $EXENAME | sed -r "s/^.*Package_(.*)$/\1/"`

if [ $TOOLVER == "V80900" ]; then
  cd $EXENAME
  wine Setup.exe
else
  cd $EXENAME/Util
  wine EnvironmentSetup.exe
fi

