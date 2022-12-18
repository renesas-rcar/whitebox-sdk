FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/runc-docker:"

SRCREV_runc-docker = "5fd4c4d144137e991c4acebb2146ab1483a97925"
SRC_URI = "git://github.com/opencontainers/runc;branch=release-1.1;name=runc-docker;protocol=https \
           file://0001-runc-Add-console-socket-dev-null.patch \
           file://0001-Makefile-respect-GOBUILDFLAGS-for-runc-and-remove-re.patch \
           file://0001-runc-docker-SIGUSR1-daemonize.patch \
          "

RUNC_VERSION = "1.1.4"
