SUMMARY = "Convert string cases between camel case, pascal case, snake case etc…"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=59260a4045da59ac7cb0820ac544b150"

inherit pypi setuptools3

PYPI_PACKAGE = "stringcase"
SRC_URI[sha256sum] = "48a06980661908efe8d9d34eab2b6c13aefa2163b3ced26972902e3bdfd87008"

BBCLASSEXTEND = "native"
