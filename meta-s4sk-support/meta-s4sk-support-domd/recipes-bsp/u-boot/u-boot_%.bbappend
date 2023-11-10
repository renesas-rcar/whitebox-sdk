FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "v2020.10/rcar-5.1.1.rc9"
SRCREV = "616f05eb5a88014037bd92ea0f1c3bfe6ea2444a"

# Backport from upstream
SRC_URI_append = " \
    file://0001-ufs-Handle-UFS-3.0-controllers.patch \
"

# Workaround for S4SK
SRC_URI_append_s4sk = " \
    file://0001-HACK-Workaround-to-use-UFS-on-S4SK.patch \
    file://0005-config-s4sk-Add-config-for-ufs.patch \
"

