FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = " \
    file://aos_servicemanager.cfg \
    file://aos-servicemanager.service \
    file://ipforwarding.conf \
"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-servicemanager.service"

RDEPENDS_${PN} += "\
    aos-rootca \
"

# Base layer for services
RDEPENDS_${PN} += "\
    python3 \
    python3-core \
"

# Kernel modules to run network containers
RDEPENDS_${PN} += "\
    kernel-module-bridge \
    kernel-module-nfnetlink \
    kernel-module-veth \
    kernel-module-xt-addrtype \
    kernel-module-xt-comment \
    kernel-module-xt-conntrack \
    kernel-module-overlay \
"

MIGRATION_SCRIPTS_PATH = "${base_prefix}/usr/share/aos/sm/migration"

AOS_RUNNER ?= "crun"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${MIGRATION_SCRIPTS_PATH} \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_servicemanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-servicemanager.service ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/src/${GO_IMPORT}/runner/aos-service@.service ${D}${systemd_system_unitdir}
    sed -i 's/runc/${AOS_RUNNER}/g' ${D}${systemd_system_unitdir}/aos-service@.service

    install -d ${D}${sysconfdir}/sysctl.d
    install -m 0644 ${WORKDIR}/ipforwarding.conf ${D}${sysconfdir}/sysctl.d

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="/src/${GO_IMPORT}/database/migration"
    if [ -d ${S}${source_migration_path} ]; then
        install -m 0644 ${S}${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

pkg_postinst_${PN}() {
    # Add aossm to /etc/hosts
    if ! grep -q 'aossm' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aossm' >> $D${sysconfdir}/hosts
    fi
}
