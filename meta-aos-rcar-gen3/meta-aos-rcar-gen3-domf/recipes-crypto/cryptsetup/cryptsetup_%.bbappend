# initramfs is build without this lib runtime
RDEPENDS_${PN} += "libgcc"

# set proper systemd tmpfiles config
EXTRA_OECONF += "--with-tmpfilesdir=${exec_prefix}/lib/tmpfiles.d"
