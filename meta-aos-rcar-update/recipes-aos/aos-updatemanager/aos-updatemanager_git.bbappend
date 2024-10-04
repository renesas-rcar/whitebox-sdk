RENESASOTA_IMPORT := "github.com/aosedge/aos-core-rcar-gen4"
python () {
    src_uri = d.getVar('SRC_URI')
    # Change to use new repository
    new_src_uri = src_uri.replace('git://github.com/aoscloud', 'git://github.com/aosedge')
    # Change fetch protocol to https
    new_src_uri = new_src_uri.replace('ssh', 'https').replace('git@', '')
    d.setVar('SRC_URI', new_src_uri)
}

