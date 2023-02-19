#!/bin/bash

TOOLPATH_T="${HOME}/.wine/drive_c/'Program Files (x86)'/'Renesas Electronics'/CS+/CC/CC-RH"
TOOLPATH=${HOME}/.wine/drive_c/'Program Files (x86)'/'Renesas Electronics'/CS+/CC/CC-RH
VERSION=`ls "${TOOLPATH}" | grep V`

BINPATH=~/.local/bin
mkdir -p ${BINPATH}

BASHHEAD="#!/bin/bash"
RLINK=${BINPATH}/rlink
CCRH=${BINPATH}/ccrh
SCRIPT=${BINPATH}/setenv

if [[ ${VERSION} == "" ]]; then
  echo "Error : Not install CCRH"
  exit -1
fi

if [[ ! -d ${TOOLPATH} ]]; then
  echo "Error : Not install CCRH"
  exit -1
fi

TOOLDIR=${TOOLPATH_T}/${VERSION}

# Make rlink shell
echo ${BASHHEAD} > ${RLINK}
echo >> ${RLINK}
echo 'wine ' ${TOOLDIR}/bin/rlink.exe '"$@"' >> ${RLINK}
chmod +x ${RLINK}

# Make ccrh shell
echo ${BASHHEAD} > ${CCRH}
echo >> ${CCRH}
echo 'wine ' ${TOOLDIR}/bin/ccrh.exe '"$@"' >> ${CCRH}
chmod +x ${CCRH}

# Environment script
echo 'export HLNK_DIR='${TOOLDIR} > ${SCRIPT}
echo  >> ${SCRIPT}
echo "PATH=${BINPATH}:"'$PATH' >> ${SCRIPT}

sudo apt install git make binutils default-jre ruby -y

echo "Completed."
