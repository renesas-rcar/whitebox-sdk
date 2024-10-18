#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
TEMPLATE="
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
"
Usage() {
    echo "Usage:"
    echo "    $0 <path_to_store_the_recipe> <recipe_name>"
    echo "example"
    echo "    $0 ./recipes-poky hello-world"
    echo "    => ./recipes-poky/hello-world/hello-world_%.bbappend is generated"
}

if [[ $# -ne 2 ]];then
    Usage; exit -1;
fi
mkdir -p $1/$2
echo "$TEMPLATE" > $1/$2/$2_%.bbappend
echo $1/$2/$2_%.bbappend is generated

