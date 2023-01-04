FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://defconfig \
    file://0001-xen-blkback-update-persistent-grants-enablement-logi.patch \
    file://xen-chosen.dtsi;subdir=git/arch/${ARCH}/boot/dts/renesas \
    file://aos.cfg \
"
