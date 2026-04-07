SUMMARY = "Reusable core utilities for various Python Packaging interoperability specifications"
LICENSE = "Apache-2.0|BSD-2"
LIC_FILES_CHKSUM = " \
    file://LICENSE.APACHE;md5=2ee41112a44fe7014dce33e26468ba93 \
    file://LICENSE.BSD;md5=7bef9bf4a8e4263634d0597e7ba100b8 \
"

inherit pypi setuptools3

PYPI_PACKAGE = "packaging"
SRC_URI[sha256sum] = "dd47c42927d89ab911e606518907cc2d3a1f38bbd026385970643f9c5b8ecfeb"

BBCLASSEXTEND = "native"
