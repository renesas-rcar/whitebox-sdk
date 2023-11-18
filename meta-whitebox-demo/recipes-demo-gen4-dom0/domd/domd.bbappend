FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append() {
    sed -i -e 's/memory = 1024/memory = 2048/' \
        -e 's/vcpus = 4/vcpus = 8/' \
        -e 's/serial@e6e60000/#serial@e6e60000/' \
        ${D}/${sysconfdir}/xen/domd.cfg
}

