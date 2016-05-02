
function post_install(){
    ln -s "${PEARL_PKGDIR}/bin/cmd" ${PEARL_HOME}/bin
}

function pre_remove(){
    rm -f ${PEARL_HOME}/bin/cmd
}
