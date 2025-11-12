FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-HACK-ufs-Force-enable-initilized-flag.patch \
    file://0002-dts-iccom-use-proper-driver-instead-of-generic-uio.patch \
    file://0003-dts-iccom-Change-iccom1-for-CR52.patch \
    file://0004-arm64-dts-renesas-r8a779f0-Fix-thermal-driver-regist.patch \
"

SRC_URI_append = " \
    file://fwe.cfg \
    file://pktgen.cfg \
    file://docker.cfg \
    file://thermal.cfg \
"

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

do_compile_prepend () {
    # Applying IPMMU WA
    sed -i ${S}/arch/${ARCH}/boot/dts/renesas/r8a779f0-${MACHINE}-xen.dts \
        -e 's/, <&ipmmu_hc 1[6-9]>//' \
        -e 's/, <&ipmmu_hc 2[0-3]>//'

    # HACK: Increase the Dom0 Memory
    sed -i ${S}/arch/${ARCH}/boot/dts/renesas/xen-chosen.dtsi -e 's/256M/512M/'

    # Remove iccom_reg passthrough
    sed -i ${S}/arch/${ARCH}/boot/dts/renesas/r8a779f0-${MACHINE}-xen.dts \
        -e 's/&iccom_reg.*//'

}

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}
