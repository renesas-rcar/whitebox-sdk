DESCRIPTION = "VEHICLE SIGNAL SPECIFICATION"
SECTION = "examples"
HOMEPAGE = "https://github.com/w3c/automotive"

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN} = "bash"
RDEPENDS_${PN}-dev = "bash"

LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=815ca599c9df247a0c7f619bab123dad"

# BRANCH = "master"
# SRC_URI = "git://github.com/COVESA/vss-tools.git;branch=${BRANCH};protocol=https"
BRANCH = "release/3.0"
SRC_URI = "git://github.com/COVESA/vehicle_signal_specification.git;branch=${BRANCH};protocol=https"
SRCREV = "525e2bd00ddf061851bdc75e849178e5d3ad5833"
UPSTREAM_CHECK_COMMITS = "1"

SRC_URI_append = " \
    file://0001-Add-Private-branch-and-sample-sensor.patch \
"

# do_configure() nothing
do_configure[noexec] = "1"

S = "${WORKDIR}/git"

do_compile_prepend () {
    cd ${S}
    git submodule update --init
    cd ${S}/vss-tools
    sed -i '17,18d' Pipfile
    python3 -m pip install pipenv
    python3 -m pipenv install --dev
    $(cd binary && gcc -shared -o binarytool.so -fPIC binarytool.c)
}

do_compile () {
    cd ${S}/vss-tools
    python3 -m pipenv run python3 \
        vspec2binary.py -I ../spec -o ../overlays/extensions/Private.vspec \
        ../spec/VehicleSignalSpecification.vspec vss_vissv2.binary
}

do_install () {
    install -d ${D}/${USRBINPATH}/waii
    install -m 644 ${S}/vss-tools/vss_vissv2.binary ${D}/${USRBINPATH}/waii
}

