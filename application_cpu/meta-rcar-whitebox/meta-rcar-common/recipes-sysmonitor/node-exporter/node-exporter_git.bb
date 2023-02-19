DESCRIPTION = "Node exporter"
LICENSE = "Apache-2.0"
VERSION = "1.4.0"
LIC_FILES_CHKSUM = "file://${S}/git-r0/src/${GO_IMPORT}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "bash"

inherit go
GO_IMPORT = "github.com/prometheus/node_exporter"
GO_INSTALL = "${GO_IMPORT}"
GOPATH="${WORKDIR}/gopath"
GOBIN="${GOPATH}/bin"
BRANCH = "master"
SRCREV = "7da1321761b3b8dfc9e496e1a60e6a476fec6018"
SRC_URI = "git://${GO_IMPORT}.git;branch=${BRANCH};protocol=https"
UPSTREAM_CHECK_COMMITS = "1"
export GOFLAGS="-modcacherw"
export CGO_ENABLED="0"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_FILENAME = "node_exporter.service"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

SRC_URI_append = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

S = "${WORKDIR}"
B = "${S}/git-r0/src/${GO_IMPORT}"

do_compile_prepend() {
    cd ${B}
    git reset --hard
    go mod tidy #  -go=1.17
}

do_compile() {
    cd ${B}
    go build node_exporter.go
}

do_install () {
    # service file
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

    # binary
    install -d ${D}/${USRBINPATH}/node_exporter
    install -m 755 ${B}/node_exporter ${D}/${USRBINPATH}/node_exporter
}

