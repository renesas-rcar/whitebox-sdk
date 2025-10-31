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
    git -C ${REPO_DIR}/${DIR_NAME} fetch --all

    remote_branches=$(git -C ${REPO_DIR}/${DIR_NAME} branch -r | grep -v 'HEAD' | sed 's/ *origin\///')
    for branch in $remote_branches; do
        git -C ${REPO_DIR}/${DIR_NAME} checkout -q -B "$branch" "origin/$branch"
    done
done

