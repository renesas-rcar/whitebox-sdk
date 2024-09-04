SRC_URI := "${@d.getVar('SRC_URI').replace('git@github.com/aoscloud', 'git@github.com/aosedge')}"
