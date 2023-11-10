FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

COMPATIBLE_MACHINE := "(spider|s4sk|generic-armv8-xt)"
OPTEEFLAVOR = "${MACHINE}_s4"

SRC_URI += " \
    file://0001-Add-support-s4sk-for-optee.patch \
    file://0002-FIX-s4sk-for-optee.patch \
"

