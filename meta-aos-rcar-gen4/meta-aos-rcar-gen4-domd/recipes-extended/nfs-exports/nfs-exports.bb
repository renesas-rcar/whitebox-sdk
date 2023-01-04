DESCRIPTION = "Export Aos states and storages folder for other nodes"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
    file://nfs.conf \
"

do_install() {
    install -d ${D}${sysconfdir}

    echo "/var/aos/storages 10.0.0.0/24(rw,no_root_squash,sync,no_wdelay,no_subtree_check)" >> ${D}${sysconfdir}/exports
    echo "/var/aos/states   10.0.0.0/24(rw,no_root_squash,sync,no_wdelay,no_subtree_check)" >> ${D}${sysconfdir}/exports

    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/nfs.conf ${D}${sysconfdir}/tmpfiles.d
}

RDEPENDS_${PN} = "packagegroup-core-nfs-server"
