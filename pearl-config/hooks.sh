
function post_install(){
    link_to_path "${PEARL_PKGDIR}/bin/cmd"

    mkdir -p ${PEARL_PKGVARDIR}/bin
    mkdir -p ${PEARL_PKGVARDIR}/cmds

    return 0
}

function post_update(){
    post_install
}

function pre_remove(){
    unlink_from_path "${PEARL_PKGDIR}/bin/cmd"
    return 0
}
