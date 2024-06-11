#!/bin/bash -eu

print_err() {
    for arr in "$@"; do
        echo -e "\e[31m$arr\e[m"
    done
}

export LANG=C
SCRIPT_DIR=$(cd `dirname $0` && pwd)
TMP_DIR=${SCRIPT_DIR}/tmp
TARGET_DIR=${SCRIPT_DIR}/CC-RH

ZIPNAME=$(find ${SCRIPT_DIR} -name "cc-rh_v*_for_linux_amd64-doc.zip")
if [[ $(echo "$ZIPNAME" | wc -l) -ne 1 ]]; then
    print_err "Error: please copy only 1 cc-rh package into tool directory."
    print_err "Script found following packages in tool directory."
    print_err "$ZIPNAME" | sed -e 's/^/    /'
    exit -1
fi

sudo apt install p7zip-full lib32stdc++6 -y

rm -rf ${TARGET_DIR}
mkdir -p ${TMP_DIR}
cd ${TMP_DIR}

unzip -d . $ZIPNAME
ls */*.deb | xargs ar vx
tar xf data.tar.*
cp -rf usr/local/Renesas/CC-RH/V* ${TARGET_DIR}
rm -rf ${TMP_DIR}

