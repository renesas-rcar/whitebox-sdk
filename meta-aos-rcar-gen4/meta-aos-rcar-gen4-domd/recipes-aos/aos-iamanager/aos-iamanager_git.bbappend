FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://aos_iamanager.cfg \
    file://aos-iamanager.service \
"

AOS_IAM_CERT_MODULES = "\
    certhandler/modules/pkcs11module \
"

AOS_IAM_IDENT_MODULES = "\
    identhandler/modules/visidentifier \
"

MIGRATION_SCRIPTS_PATH = "${base_prefix}/usr/share/aos/iam/migration"

inherit systemd

SYSTEMD_SERVICE_${PN} = "aos-iamanager.service"

FILES_${PN} += " \
    ${sysconfdir} \
    ${systemd_system_unitdir} \
    ${MIGRATION_SCRIPTS_PATH} \
"

RDEPENDS_${PN} = " \
    aos-provfirewall \
    aos-provfinish \
    aos-rootca \
    aos-setupdisk \
    optee-os \
    optee-client \
"

do_install_append() {
    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_iamanager.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-iamanager.service ${D}${systemd_system_unitdir}

    install -d ${D}${MIGRATION_SCRIPTS_PATH}
    source_migration_path="/src/${GO_IMPORT}/database/migration"
    if [ -d ${S}${source_migration_path} ]; then
        install -m 0644 ${S}${source_migration_path}/* ${D}${MIGRATION_SCRIPTS_PATH}
    fi
}

pkg_postinst_${PN}() {
    # Add aosiam to /etc/hosts
    if ! grep -q 'aosiam' $D${sysconfdir}/hosts ; then
        echo '127.0.0.1	aosiam' >> $D${sysconfdir}/hosts
    fi
}
