FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_compile_prepend() {
    sed -i 's/defaultRequestTimeout = 1/defaultRequestTimeout = 5/' \
        ${S}/src/github.com/aoscloud/aos_iamanager/config/config.go
}
