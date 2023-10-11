#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0` && pwd)
repolist_gen3=(\
    "https://github.com/yoctoproject/poky" \
    "https://github.com/openembedded/meta-openembedded" \
    "https://github.com/renesas-rcar/meta-renesas" \
    "https://github.com/yhamamachi/meta-rcar-dev-utils" \
    "https://github.com/OSSystems/meta-browser" \
    "https://github.com/kraj/meta-clang" \
    "https://github.com/renesas-rcar/meta-renesas-ccpf" \
)

repolist_gen4=(\
    "https://github.com/yoctoproject/poky" \
    "https://github.com/openembedded/meta-openembedded" \
    "git://git.yoctoproject.org/meta-virtualization" \
    "git://git.yoctoproject.org/meta-arm" \
    "https://github.com/xen-troops/meta-xt-common.git" \
    "https://github.com/aoscloud/meta-aos-rcar-gen4.git" \
    "https://github.com/renesas-rcar/meta-renesas.git" \
    "git://git.yoctoproject.org/meta-selinux" \
    "git://git.yoctoproject.org/meta-security" \
    "https://github.com/aoscloud/meta-aos.git" \
    "https://github.com/renesas-rcar/whitebox-sdk.git" \
)

REPO_DIR=${SCRIPT_DIR}/work/repo
mkdir -p $REPO_DIR
for repo in ${repolist_gen3[@]} ${repolist_gen4[@]}; do
    DIR_NAME=$(echo $repo | rev | cut -d'/' -f1 | rev | sed 's/.git//')
    # echo $repo: dir_name is $DIR_NAME
    if [ ! -d ${REPO_DIR}/${DIR_NAME} ]; then
        git clone $repo ${REPO_DIR}/${DIR_NAME}
    fi
    cd ${REPO_DIR}/${DIR_NAME} && git pull
done

