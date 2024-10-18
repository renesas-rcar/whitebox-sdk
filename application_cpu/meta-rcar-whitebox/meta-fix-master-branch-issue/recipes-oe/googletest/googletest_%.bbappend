
python () {
    src_uri = d.getVar('SRC_URI')
    if 'branch=master' in src_uri:
        # Change to use main branch
        new_src_uri = src_uri.replace('branch=master', 'branch=main')
    else:
        # Add branch=main
        new_src_uri = src_uri.replace('.git', '.git;branch=main')
    d.setVar('SRC_URI', new_src_uri)
}

