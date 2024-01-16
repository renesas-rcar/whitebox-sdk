#!/bin/bash -eu

SCRIPT_DIR=$(cd `dirname $0` && pwd)
repolist=$(grep -h url: ./*.yaml | grep -v "^#" | awk '{print $2}' | sed 's/"//g' )
REPO_DIR=${SCRIPT_DIR}/common_data/repo

mkdir -p $REPO_DIR
for repo in ${repolist[@]}; do
    DIR_NAME=$(echo $repo | rev | cut -d'/' -f1 | rev | sed 's/.git//')
    # echo $repo: dir_name is $DIR_NAME
    if [ ! -d ${REPO_DIR}/${DIR_NAME} ]; then
        git clone $repo ${REPO_DIR}/${DIR_NAME}
    fi
    cd ${REPO_DIR}/${DIR_NAME} && git pull
done

