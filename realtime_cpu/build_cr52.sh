#!/bin/bash -eu

mkdir -p zephyrproject
cd zephyrproject
export ZEPHYR_DIR=$(pwd)

python3 -m venv ${ZEPHYR_DIR}/.venv
source ${ZEPHYR_DIR}/.venv/bin/activate

pip install wheel
pip install west

cd ${ZEPHYR_DIR}
if [ ! -e "./.west/config" ]; then
    west init -m  https://github.com/iotbzh/zephyr.git --manifest-rev 2022-12-20-s4sk ${ZEPHYR_DIR}
fi
west update

west zephyr-export
pip install -r ${ZEPHYR_DIR}/zephyr/scripts/requirements.txt

cd ${ZEPHYR_DIR}
wget -c https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.15.2/zephyr-sdk-0.15.2_linux-x86_64.tar.gz
tar xvf zephyr-sdk-0.15.2_linux-x86_64.tar.gz

cd zephyr-sdk-0.15.2
./setup.sh -c

cd ${ZEPHYR_DIR}/zephyr
west build -p always -b rcar_spider_cr52 samples/basic/blinky
${ZEPHYR_DIR}/zephyr-sdk-0.15.2/arm-zephyr-eabi/bin/arm-zephyr-eabi-objcopy --adjust-vma 0xe2100000 -O srec --srec-forceS3  build/zephyr/zephyr.elf build/zephyr/zephyr.srec

