FILES_${PN} += " \
    ${@bb.utils.contains('DISTRO_FEATURES','systemd','${exec_prefix}/lib/tmpfiles.d/lvm2.conf', '', d)} \
"

EXTRA_OECONF += "--with-tmpfilesdir=${exec_prefix}/lib/tmpfiles.d"

do_install_append () {
    # install tmpfiles config
    oe_runmake 'DESTDIR=${D}' install_tmpfiles_configuration

    # put cache, backup etc. into RW /var/lvm
    sed -i "s:/etc:/var:g" ${D}${sysconfdir}/lvm/lvm.conf
}
