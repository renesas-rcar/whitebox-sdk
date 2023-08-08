#!/bin/bash

SOURCE_DISK=/dev/mmcblk0
TARGET_DISK=/dev/sda

echo "=============================="
echo "= disk image copy script     ="
echo "=============================="
echo ""
echo "Copy ${SOURCE_DISK} to ${TARGET_DISK}"
echo ""
echo "This script will be run after 10 sec."
echo "if you want to stop this script, please enter the CTRL+C"
echo ""

sleep 10

echo "Copy the image..."
set -x
EOD_S=$(fdisk -l ${SOURCE_DISK} 2>/dev/null | tail -1 | awk '{print $3}')
EOD_T=$(fdisk -l ${TARGET_DISK} 2>/dev/null | tail -1 | awk '{print $3}')
BS_S=$(fdisk -l ${SOURCE_DISK} 2>/dev/null | grep Units | awk '{print $8}')
BS_T=$(fdisk -l ${TARGET_DISK} 2>/dev/null| grep Units | awk '{print $8}')
BS=512
dd if=${SOURCE_DISK} of=${TARGET_DISK} bs=${BS} ibs=${BS_S} obs=${BS_T} count=${EOD_S}
set +x

echo "Setup partition..."
set +x
SIZE_LIST=$(fdisk -l ${SOURCE_DISK} | grep ${SOURCE_DISK}p | awk '{print $5}' | xargs echo)
wipefs -a ${TARGET_DISK} # Remove All partitions
echo "label: gpt" | sfdisk ${TARGET_DISK} # Setup GPT label
for size in ${SIZE_LIST}; do
fdisk ${TARGET_DISK} << EOS
n


+$size
w
EOS
done
set -x

echo "Sync device..."
set -x
sync
set +x

echo "Finished."

