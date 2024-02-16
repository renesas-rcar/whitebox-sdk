FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

BRANCH = "v2020.10/rcar-5.1.1.rc10"
SRCREV = "9ddd54cbb5d2e65fab77bede0b1db35dca539848"

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
    file://0007-configs-s4sk-Add-missing-config-from-spider.patch \
    file://0004-clk-renesas-Add-and-enable-CPG-reset-driver-for-Gen4.patch \
    file://0005-ufs-reset-UFS-controller-on-init.patch \
"

# Backport from upstream
SRC_URI_append = " \
    file://0001-ufs-Handle-UFS-3.0-controllers.patch \
"

# Workaround for S4SK
SRC_URI_append_s4sk = " \
    file://0001-HACK-Workaround-to-use-UFS-on-S4SK.patch \
    file://0002-s4sk-Update-default-environmet-variable-for-Whitebox.patch \
"

SRC_URI_append_spider = " \
    file://0001-spider-Update-default-environmet-variable-for-Whiteb.patch \
"

