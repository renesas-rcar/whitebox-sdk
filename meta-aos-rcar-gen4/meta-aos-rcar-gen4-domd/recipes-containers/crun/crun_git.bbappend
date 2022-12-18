LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRCREV_crun = "18cf2efbb8feb2b2f20e316520e0fd0b6c41ef4d"
SRCREV_libocispec = "65bdde6f82b5ce8cddc316b8f93e30bc1c35e333"
SRCREV_ispec = "199b07a0baf59d29b858a10f577161f5bb52ccd4"
SRCREV_rspec = "494a5a6aca782455c0fbfc35af8e12f04e98a55e"
SRCREV_yajl = "49923ccb2143e36850bcdeb781e2bcdf5ce22f15"

SRC_URI = " \
    git://github.com/containers/crun.git;branch=main;name=crun;protocol=https \
    git://github.com/containers/libocispec.git;branch=main;name=libocispec;destsuffix=git/libocispec;protocol=https \
    git://github.com/opencontainers/runtime-spec.git;branch=main;name=rspec;destsuffix=git/libocispec/runtime-spec;protocol=https \
    git://github.com/opencontainers/image-spec.git;branch=main;name=ispec;destsuffix=git/libocispec/image-spec;protocol=https \
    git://github.com/containers/yajl.git;branch=main;name=yajl;destsuffix=git/libocispec/yajl;protocol=https \
"

PV = "1.6.0+git${SRCREV_crun}"

inherit features_check

REQUIRED_DISTRO_FEATURES ?= "systemd seccomp"

DEPENDS += "systemd"

do_configure:prepend () {
    # extracted from autogen.sh in crun source. This avoids
    # git submodule fetching.
    mkdir -p m4
    autoreconf -fi
}
