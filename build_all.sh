#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
GEN4_ICUMX_LOADER_PKG=$(ls ${SCRIPT_DIR}/proprietary/ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv*.zip | tail -1)

Usage () {
    echo "Usage: $0 <gen4_board_name>"
    echo "gen4_board_name:"
    echo "    - s4sk"
    echo "    - spider"
}

if [[ $# -ne 1 ]]; then
    Usage; exit -1
fi
if [[ "$1" != "s4sk" ]] && [[ "$1" != "spider" ]]; then
    Usage; exit -1
fi
echo $GEN4_ICUMX_LOADER_PKG
if [[ ! -e "$GEN4_ICUMX_LOADER_PKG" ]]; then
    echo "Error: ICUMX loader package is not found in proprietary directory"
    echo "Please put package as follows:"
    echo "   ex.) proprietary/ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDKv3.16.2.zip"
    exit -1
fi

GEN4_BOARD=$1
GEN3_BOARD=h3sk

###########################
# Main process            #
###########################
cd $SCRIPT_DIR
rm -rf deploy
mkdir -p deploy

./build_s4.sh $GEN4_BOARD -cu
cp work-s4/gen4_full.img.gz deploy/$GEN4_BOARD.ufs.full.img.gz
unzip -d deploy $GEN4_ICUMX_LOADER_PKG
mv deploy/ICUMX_Loader_and_Flashwriter_Package_for_R-Car_S4_Starter_Kit_SDK* deploy/${GEN4_BOARD}_ipl
cp work-s4/yocto/build/gen4/domd/tmp/deploy/images/$GEN4_BOARD/*.srec -t deploy/${GEN4_BOARD}_ipl
mv deploy/${GEN4_BOARD}_ipl/Flash_Bootloader_S4SK.ttl deploy/${GEN4_BOARD}_ipl/Flash_Bootloader_S4.ttl
sed -i "s/s4sk/${GEN4_BOARD}/" deploy/${GEN4_BOARD}_ipl/Flash_Bootloader_S4.ttl

./build_h3.sh h3ulcb-4x2g -cdf
cp work/gen3_full.img.gz deploy/$GEN3_BOARD.mmc.full.img.gz
cp -r work/yocto/build/gen3/domd/tmp/deploy/images/h3ulcb/firmware \
    ./deploy/${GEN3_BOARD}_ipl
cp work/yocto/build/gen3/domd/tmp/deploy/images/h3ulcb/*.srec \
    ./deploy/${GEN3_BOARD}_ipl/
cp -r work/yocto/build/gen3/domd/tmp/deploy/images/h3ulcb/renesas-bsp-rom-writer_64bit \
    ./deploy/${GEN3_BOARD}_ipl/

ls deploy/
echo "Build finished"

