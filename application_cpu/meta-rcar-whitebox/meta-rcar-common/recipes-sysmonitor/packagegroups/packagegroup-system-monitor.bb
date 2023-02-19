SUMMARY = "Packagegroup for System monitor"
LICENSE = "AGPL-3.0 & Apache-2.0"

inherit packagegroup

PR = "r0"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PACKAGES = " \
    ${PN} \
"

RDEPENDS_${PN} = " \
    grafana \
    node-exporter \
    prometheus \
"


