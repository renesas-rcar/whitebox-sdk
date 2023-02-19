DESCRIPTION = "Prometheus"
LICENSE = "Apache-2.0"
VERSION = "2.39.0"
LIC_FILES_CHKSUM = "file://${S}/git-r0/src/${GO_IMPORT}/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "bash"

inherit go
GO_IMPORT = "github.com/prometheus/prometheus"
GO_INSTALL = "${GO_IMPORT}"
GOPATH="${WORKDIR}/gopath"
GOBIN="${GOPATH}/bin"
BRANCH = "main"
SRCREV = "6d7f26c46ff70286944991f95d791dff03174eea"
SRC_URI = "git://${GO_IMPORT}.git;branch=${BRANCH};protocol=https"
UPSTREAM_CHECK_COMMITS = "1"
export GOFLAGS="-modcacherw"
export CGO_ENABLED="0"

inherit systemd
SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE_FILENAME = "prometheus.service"
SYSTEMD_SERVICE_${PN} = "${SYSTEMD_SERVICE_FILENAME}"

inherit npm

SRC_URI_append = " \
    file://${SYSTEMD_SERVICE_FILENAME} \
"

S = "${WORKDIR}"
B = "${S}/git-r0/src/${GO_IMPORT}"

do_configure () {
    :
}

do_compile_prepend() {
    cd ${B}
    git reset --hard
    go mod tidy #  -go=1.17
    sed -i 's/,builtinassets//' .promu.yml

    cd ${B}/web/ui/
    rm -rf ./package-lock.json
    npm install
    npm run build
}

do_compile() {
    cd ${B}
    go build ./cmd/prometheus
}

do_install () {
    # service file
    install -d ${D}/${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/${SYSTEMD_SERVICE_FILENAME} ${D}/${systemd_unitdir}/system

    # binary
    install -d ${D}/${USRBINPATH}/${PN}
    install -m 755 ${B}/${PN} ${D}/${USRBINPATH}/${PN}
    install -m 644 ${B}/documentation/examples/prometheus.yml ${D}/${USRBINPATH}/${PN}
    cp -r ${B}/web ${D}/${USRBINPATH}/${PN}

    # Edit config file
    echo '  - job_name: "node"' >> ${D}/${USRBINPATH}/${PN}/prometheus.yml
    echo '    scrape_interval: 1s' >> ${D}/${USRBINPATH}/${PN}/prometheus.yml
    echo '    static_configs:' >> ${D}/${USRBINPATH}/${PN}/prometheus.yml
    echo '    - targets: ["localhost:9100"]' >> ${D}/${USRBINPATH}/${PN}/prometheus.yml
}

