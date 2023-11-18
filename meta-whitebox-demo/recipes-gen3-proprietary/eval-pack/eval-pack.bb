SUMMARY = "Unpack multimedia evaluation packages"
DESCRIPTION = ""

PV = "0.1"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

#####
# How this recipe works
#
# With each BSP version manufacturer provides evaluation package
#   for support of multimedia features like audio/video encode/decode.
# These archives are named as `R-Car_Gen3_Series_Evaluation_Software_Package_*.zip`
#   and considered as "level 1" in terms of this recipe.
# "Level 1" archives contains set of "level 2" archives with separate
#   feature specific content - like archive for MP3 decoder.
# "Level 2" archives contains some text document and "level 3" archive,
#   that is tar'ed sources and proprietary binaries, that are supposed
#   to be handled by yocto.
#
# This recipe:
# - looks for "level 1" archives (mask for filenames is specified in
#   `L1_PACKAGE_MASK` variable) in `XT_MULTIMEDIA_EVA_DIR` and unpack
#   them into ${L2_DIR} subfolder
# - unpack `*.tar.*` files from `${L2_DIR}/*.zip` into ${MM_EVA_L3_DIR}.
#
# Any recipe that want to use these unpacked L3 files need to use following lines:
#   FILESEXTRAPATHS_append := "${MM_EVA_L3_DIR}:"
#   require include/eval-pack.inc
#   do_fetch[depends] = "eval-pack:do_unpack"
#####

L1_PACKAGE_MASK = "R-Car_Gen3_Series_Evaluation_Software_Package_*.zip"

L2_DIR = "${TOPDIR}/../unpacked_L2/"

# MM_EVA_L3_DIR is defined in .inc file because it need to be used in multiple places
require include/eval-pack.inc

do_unpack() {
    if [ ! -z ${XT_MULTIMEDIA_EVA_DIR} ]; then
        # Level 1, R-Car_Gen3_Series_Evaluation_Software_Package_*.zip, provided by manufacturer.
        for L1_ARCHIVE in ${XT_MULTIMEDIA_EVA_DIR}/${L1_PACKAGE_MASK}
        do
            unzip -qo ${L1_ARCHIVE} -d ${L2_DIR}
        done

        # Level 2, intermediate archives
        for L2_ARCHIVE in ${L2_DIR}/*.zip
        do
            unzip -qoj ${L2_ARCHIVE} *.tar.* -d ${MM_EVA_L3_DIR}
        done

        # Rename INF package
        mv ${MM_EVA_L3_DIR}/INF_r8a77951_linux_gsx_binaries_gles.tar.bz2 \
            ${MM_EVA_L3_DIR}/r8a77951_linux_gsx_binaries_gles.tar.bz2
        mv ${MM_EVA_L3_DIR}/INF_r8a77960_linux_gsx_binaries_gles.tar.bz2 \
            ${MM_EVA_L3_DIR}/r8a77960_linux_gsx_binaries_gles.tar.bz2
    fi
}
