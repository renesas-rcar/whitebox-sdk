DESCRIPTION = "vehicle-information-service-specification-reference-implementation (VISSR)"
SECTION = "examples"
HOMEPAGE = "https://covesa.github.io/vissr/"

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "bash vss"
RDEPENDS_${PN}-dev = "bash vss"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

BRANCH = "master"
SRC_URI = "git://${GO_IMPORT};branch=${BRANCH};protocol=https"
SRCREV = "576498184224cce2f9aac1e977652f9e4125d6a8"
UPSTREAM_CHECK_COMMITS = "1"

inherit go
GO_IMPORT = "github.com/COVESA/vissr"
GO_INSTALL = "${GO_IMPORT}/server"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_FILENAMES = " \
    ${BPN}.target \
    agt_server.service \
    vissv2server.service \
"
SRC_URI_append = " \
    file://${BPN}.target \
    file://agt_server.service \
    file://vissv2server.service \
"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAMES}"

do_compile_prepend() {
    cd ${S}/src/${GO_IMPORT}
    sed -i -e 's|.* => /home/.*||' \
        -e 's|w3c/automotive-viss2/|COVESA/vissr/|g' ./go.mod
    # find ./ -name "*.go" | \
    #     xargs -i sed -i -e 's|w3c/automotive-viss2/|COVESA/vissr/|g' {}
    go mod tidy -modcacherw
    cd ${S}/src/${GO_IMPORT}/server
    go mod tidy -modcacherw
    sed -i 's|"vss_vissv2.binary"|"../vss_vissv2.binary"|' ./vissv2server/vissv2server.go
}

services="vissv2server agt_server"
do_compile() {
    for service in ${services}; do \
        cd ${S}/src/${GO_IMPORT}/server/${service}
        go build -modcacherw
    done
}

FILES_${PN} = " \
    ${USRBINPATH}/${BPN}/* \
    /var/* \
"

DBFILE_PATH = "${S}/src/${GO_IMPORT}/server/vissv2server/serviceMgr/statestorage.db"

do_install() {
    # service file
    install -d ${D}/${systemd_unitdir}/system
    for service in ${SYSTEMD_SERVICE_FILENAMES}; do \
        install -m 0644 ${WORKDIR}/${service} ${D}/${systemd_unitdir}/system
    done

    # binary
    install -d ${D}/${USRBINPATH}/${BPN}
    for service in ${services} transport_sec; do \
        cp -r ${S}/src/${GO_IMPORT}/server/${service} \
            ${D}/${USRBINPATH}/${BPN}/
    done
    # Remove source code from directory
    find ${D}/${USRBINPATH}/${BPN}/ -name "*.go" \
        | xargs rm -f

    # Copy dbfile
    install -d ${D}/var
    install -m 0644 ${DBFILE_PATH} ${D}/var
}

inherit deploy
do_deploy() {
    # Copy Database file to deploy directory
    install -d {${DEPLOY_DIR_IMAGE}
    install -m 0644 ${DBFILE_PATH} ${DEPLOY_DIR_IMAGE}
}
addtask deploy before do_build after do_compile

