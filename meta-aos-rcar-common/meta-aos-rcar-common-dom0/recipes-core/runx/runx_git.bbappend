FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRCREV_runx = "0c7edb3453398d7a0c594ce026c9c1e93c2541cc"

SRC_URI = " \
    git://github.com/lf-edge/runx;nobranch=1;name=runx \
    file://0001-files-create-Update-create-script-to-start-unikernel.patch \
"

SRC_URI[md5sum] = "ce9b2d974d27408a61c53a30d3f98fb9"
SRC_URI[sha256sum] = "bf338980b1670bca287f9994b7441c2361907635879169c64ae78364efc5f491"

PV = "v1.1-git${SRCREV_runx}"

REQUIRED_DISTRO_FEATURES_remove = "vmsep"

DEPENDS_remove = "busybox go-build openssl-native coreutils-native util-linux-native"
DEPENDS_remove = "xz-native bc-native qemu-native"

RDEPENDS_${PN}_remove = "go-build"

RUNX_USE_INTERNAL_BUSYBOX ?= ""

do_compile() {
    export CC="${CC}"
    export LD="${LD}"
    export CFLAGS="${HOST_CC_ARCH}${TOOLCHAIN_OPTIONS} ${CFLAGS}"
    export LDFLAGS="${TOOLCHAIN_OPTIONS} ${HOST_LD_ARCH} ${LDFLAGS}"
    export HOSTCFLAGS="${BUILD_CFLAGS} ${BUILD_LDFLAGS}"
    export CROSS_COMPILE="${TARGET_PREFIX}"
    export ARCH="%{TARGET_PREFIX}"
    cd ${S}/sendfd
    make
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${S}/runX ${D}${bindir}

    install -d ${D}${datadir}/runX
    install -m 755 ${S}/files/start ${D}/${datadir}/runX
    install -m 755 ${S}/files/create ${D}/${datadir}/runX
    install -m 755 ${S}/files/state ${D}/${datadir}/runX
    install -m 755 ${S}/files/delete ${D}/${datadir}/runX
    install -m 755 ${S}/files/pause ${D}/${datadir}/runX
    install -m 755 ${S}/files/mount ${D}/${datadir}/runX
    install -m 755 ${S}/files/serial_start ${D}/${datadir}/runX
    install -m 755 ${S}/sendfd/sendfd ${D}/${datadir}/runX
}
