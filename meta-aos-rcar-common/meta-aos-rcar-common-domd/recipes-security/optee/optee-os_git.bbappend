FILESEXTRAPATHS_prepend := "${THISDIR}/optee-os:"

SRC_URI = "git://github.com/OP-TEE/optee_os.git"
# optee-os 3.18.0
SRCREV = "1ee647035939e073a2e8dddb727c0f019cc035f1"

SRC_URI += " \
    file://0001-plat-rcar-fix-core-pos-calculation-for-H3-boards.patch \
"

DEPENDS += "python3-cryptography-native"
