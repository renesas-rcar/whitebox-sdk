DESCRIPTION = "OP-TEE Client"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=69663ab153298557a59c67a60a743e5b"

SRC_URI = "git://github.com/OP-TEE/optee_client.git"
SRC_URI += " \
    file://optee.service \
"
# optee-client 3.18.0
SRCREV = "e7cba71cc6e2ecd02f412c7e9ee104f0a5dffc6f"

PV = "3.18.0+git${SRCPV}"

inherit python3native systemd

DEPENDS = "python3-cryptography-native"

SYSTEMD_SERVICE_${PN} = "optee.service"

COMPATIBLE_MACHINE = "(salvator-x|h3ulcb|m3ulcb|m3nulcb|spider|generic-armv8-xt)"

PACKAGE_ARCH = "${MACHINE_ARCH}"

S = "${WORKDIR}/git"

EXTRA_OEMAKE = " \
    RPMB_EMU=0 \
    CFG_TEE_FS_PARENT_PATH=/var/optee \
"

do_install () {
    # Create destination directories
    install -d ${D}/${libdir}
    install -d ${D}/${bindir}
    install -d ${D}/${includedir}

    # Install libraries
    install -m 0644 ${S}/out/export/usr/lib/libteec.so.1.0.0 ${D}/${libdir}
    install -D -p -m 0644 ${S}/out/export/usr/lib/libckteec.so.0.1 ${D}${libdir}
    # Create symbolic links
    lnr ${D}${libdir}/libteec.so.1.0.0  ${D}${libdir}/libteec.so.1.0
    lnr ${D}${libdir}/libteec.so.1.0.0  ${D}${libdir}/libteec.so.1
    lnr ${D}${libdir}/libteec.so.1.0.0  ${D}${libdir}/libteec.so

    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so.0
    lnr ${D}${libdir}/libckteec.so.0.1 ${D}${libdir}/libckteec.so

    # Install header files
    install -m 0644 ${S}/out/export/usr/include/* ${D}/${includedir}

    # Install binary to bindir
    install -m 0755 ${S}/out/export/usr/sbin/tee-supplicant ${D}/${bindir}

    # Install systemd service configure file for OP-TEE client
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}/${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/optee.service ${D}/${systemd_system_unitdir}
    fi
}

RPROVIDES_${PN} += "optee-client"

