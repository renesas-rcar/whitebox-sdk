FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "v2020.10/rcar-5.1.1.rc9"
SRCREV = "616f05eb5a88014037bd92ea0f1c3bfe6ea2444a"

SRC_URI_append = " \
    file://0001-HACK-Improve-large-file-download-via-TFTP.patch \
"

# UFS support patchset
SRC_URI_append = " \
    file://0001-ufs-flush-invalidate-command-buffer.patch \
    file://0002-arm-dts-r8a779f0-Add-Renesas-UFS-HCD-support.patch \
    file://0003-ufs-port-linux-driver-for-rcar-ufshcd.patch \
    file://0004-config-spider-Add-config-for-ufs.patch \
    file://0005-config-s4sk-Add-config-for-ufs.patch \
    file://0006-arm-dts-r8a779f0-s4sk-Add-Renesas-UFS-HCD-support.patch \
"

# Backport from upstream
SRC_URI_append = " \
    file://0001-ufs-Handle-UFS-3.0-controllers.patch \
"

# Workaround for S4SK
SRC_URI_append_s4sk = " \
    file://0001-HACK-Workaround-to-use-UFS-on-S4SK.patch \
"

