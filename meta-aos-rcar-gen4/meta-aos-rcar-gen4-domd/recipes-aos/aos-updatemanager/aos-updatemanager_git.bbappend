FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RENESASOTA_IMPORT = "github.com/aoscloud/aos-core-rcar-gen4"

SRC_URI_append = " \
    git://git@${RENESASOTA_IMPORT}.git;branch=main;protocol=ssh;name=renesasota;destsuffix=${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT} \
"

SRCREV_FORMAT = "renesasota"
SRCREV_renesasota = "0b701b26bc5f7b663e331a9d6ec426f28b7a01a7"

FILES_${PN} += " \
    ${bindir} \
"

do_prepare_modules_append() {
    file="${S}/src/${GO_IMPORT}/updatemodules/modules.go"

    echo 'import _ "${RENESASOTA_IMPORT}/updatemodules/renesasota"' >> ${file}
}

do_compile() {
    VENDOR_PACKAGES=" \
        github.com/syucream/posix_mq \
        github.com/aoscloud/aos_common/aostypes \
    "

    for package in $VENDOR_PACKAGES; do
        install -d $(dirname ${S}/src/${GO_IMPORT}/vendor/${package})
        ln -sfr ${S}/src/${GO_IMPORT}/vendor/${RENESASOTA_IMPORT}/vendor/${package} ${S}/src/${GO_IMPORT}/vendor/${package}
    done 

    cd ${S}/src/${GO_IMPORT}
    GO111MODULE=on ${GO} build -o ${B}/bin/aos_updatemanager -ldflags "-X main.GitSummary=`git --git-dir=.git describe --tags --always`"
}

do_install_append() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/bin/aos_updatemanager ${D}${bindir}
}
