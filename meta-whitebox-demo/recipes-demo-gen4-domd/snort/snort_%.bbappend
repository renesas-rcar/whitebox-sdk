DESCRIPTION = "Append snort config"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install_append() {
    echo 'include $RULE_PATH/local.rules' >> ${D}/etc/snort/snort.conf
    echo 'drop icmp any any -> $HOME_NET any (GID:1; sid: 10000001;)' >> ${D}/etc/snort/rules/local.rules
    echo 'drop tcp any any -> 192.168.137.0/24 :3000 (GID:1; sid: 10000002;)' >> ${D}/etc/snort/rules/local.rules

    echo 'blacklist_expired_timeout: 15'  >> ${D}/etc/snort/rswitch.conf
}

FILES_${PN} += "\
    /etc/snort/snort.conf \
"

