FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Move IPLs into 'firmware' folder
inherit collect_firmware

# To start CPU cores in EL2 mode we need to compile IPLs with the
# option `RCAR_BL33_EXECUTION_EL=1`. But original recipe has
# complilation of loaders separated into two different functions:
# do_compile() and do_ipl_opt_compile().
#
# do_compile() produces binaries for SOC/board without memory variants
# and without memory suffix (e.g. bl2-h3ulcb.bin).
# We can use `ATFW_OPT` variable to append our parameters to do_compile().
# We use it for M3 related builds.
#
# do_ipl_opt_compile() produces IPLs for boards with different memory
# variants, and with memory suffixes, like bl2-h3ulcb-4x2g.bin.
# do_ipl_opt_compile() INTERNALLY uses variables `EXTRA_ATFW_OPT` and
# `EXTRA_ATFW_CONF` to provide parameters to compiler.
# `EXTRA_ATFW_OPT` is set by values described in variable flags like
# `H3ULCB[4x2g]` inside `do_extra_aft_build()`.
# So only way to provide our parameter to the compiler through
# do_ipl_opt_compile() is to append to these varFlags using
# += or d.appendVarFlag().
#
# On top of that, we have separate do_ipl_opt_compile() function for
# Kingfisher board (h3ulcb-4x2g-kf). But it uses same `EXTRA_ATF_OPT`
# to provide paramaters to compiler.
#
# Pay attention that we only append to boards supported by our products.
#
# M3 related boards have no memory variants
ATFW_OPT_append = " RCAR_BL33_EXECUTION_EL=1"
# H3 related boards with memory variants
H3ULCB[4x2g] += "RCAR_BL33_EXECUTION_EL=1"
H3[2x2g] += "RCAR_BL33_EXECUTION_EL=1"
H3[4x2g] += "RCAR_BL33_EXECUTION_EL=1"

SRC_URI += "\
    file://0001-rcar-gen3-plat-fix-copy-paste-issue-with-runtime-con.patch \
    file://0002-rcar-gen3-ulcb-enable-GPIO-clocks-before-accessing-t.patch \
"

do_deploy_append () {
    install -m 0644 ${S}/tools/renesas/rcar_layout_create/bootparam_sa0.bin ${DEPLOYDIR}/bootparam_sa0.bin
#     install -m 0644 ${S}/tools/renesas/rcar_layout_create/cert_header_sa6.bin ${DEPLOYDIR}/cert_header_sa6.bin
#     install -m 0644 ${S}/tools/renesas/rcar_layout_create/cert_header_sa6_emmc.bin ${DEPLOYDIR}/cert_header_sa6_emmc.bin
#     install -m 0644 ${S}/tools/renesas/rcar_layout_create/cert_header_sa6_emmc.srec ${DEPLOYDIR}/cert_header_sa6_emmc.srec
}

