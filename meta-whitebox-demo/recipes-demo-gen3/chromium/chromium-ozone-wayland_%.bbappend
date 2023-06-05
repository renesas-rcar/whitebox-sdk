FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

def get_additional_patch (d):
    if d.getVar("USING_CCPF_SK", True) == "1":
        return ""
    else:
        return "file://Fix-dri-error.patch"

SRC_URI_append = "${@get_additional_patch(d)}"

