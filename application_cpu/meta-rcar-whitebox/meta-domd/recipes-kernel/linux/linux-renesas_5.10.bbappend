FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RENESAS_BSP_URL_spider = "git://github.com/xen-troops/linux.git"
BRANCH_spider = "v5.10.41/rcar-5.1.7.rc6-xt"
SRCREV_spider = "f5bb327b43cc6248cde9f3baf18e64257be8bc02"

USE_UFS_SPIDER = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag.patch \
"
USE_UFS_S4SK = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag-for-S4SK.patch \
"

SRC_URI_append_spider = " \
    file://0001-dts-iccom-use-proper-driver-instead-of-generic-uio.patch \
    file://0002-dts-iccom-Change-iccom1-for-CR52.patch \
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_SPIDER}", "", d)} \
"

SRC_URI_append_s4sk = " \
    file://0001-dts-iccom-use-proper-driver-instead-of-generic-uio-s4sk.patch \
    file://0002-dts-iccom-Change-iccom1-for-CR52.patch \
    ${@oe.utils.conditional("USE_UFS", "1", "${USE_UFS_S4SK}", "", d)} \
"

SRC_URI_append = " \
    file://fwe.cfg \
    file://pktgen.cfg \
    file://docker.cfg \
"

# Add support thermal driver
SRC_URI_append = " \
    file://thermal.cfg \
    file://0001-arm64-dts-renesas-r8a779f0-Fix-thermal-driver-regist.patch \
"

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

# Applying IPMMU WA
do_compile_prepend () {
    sed -i ${S}/arch/${ARCH}/boot/dts/renesas/r8a779f0-${MACHINE}-xen.dts \
        -e 's/, <&ipmmu_hc 1[6-9]>//' \
        -e 's/, <&ipmmu_hc 2[0-3]>//'
}

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}
