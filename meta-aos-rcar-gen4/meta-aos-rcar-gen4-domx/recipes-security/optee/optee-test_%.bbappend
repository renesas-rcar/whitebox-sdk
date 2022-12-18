COMPATIBLE_MACHINE = "spider"

PV = "3.17.0+git${SRCPV}"

DEPENDS += "python3-cryptography-native"

SRCREV = "44a31d02379bd8e50762caa5e1592ad81e3339af"

EXTRA_OEMAKE += " \
    LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
"
