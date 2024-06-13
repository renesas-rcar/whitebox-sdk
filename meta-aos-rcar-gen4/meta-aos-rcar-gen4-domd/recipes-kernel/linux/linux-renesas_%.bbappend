FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL = "git://github.com/xen-troops/linux.git"
BRANCH = "${XT_KERNEL_BRANCH}"
SRCREV = "${XT_KERNEL_REV}"

SRC_URI_append = "\
    file://defconfig \
"

SRC_URI_append = " \
    file://r8a779f0.cfg \
    file://rswitch.cfg \
    file://dmatest.cfg \
    file://aos.cfg \
    file://gpio.cfg \
    file://l3offload.cfg \
    file://ixgbe.cfg \
    file://ufs.cfg \
    file://xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://0001-xen-blkback-update-persistent-grants-enablement-logi.patch \
"

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}

KERNEL_MODULE_PROBECONF += "ixgbevf"
module_conf_ixgbevf = "blacklist ixgbevf"
