FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Start cores in EL2 mode
SRC_URI += "\
    file://0001-HACK-s4-boot-U-Boot-in-EL2-mode.patch \
    file://0002-HACK-s4-Configure-IPMMU-registers.patch \
"
