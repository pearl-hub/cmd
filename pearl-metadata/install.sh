
function post_install(){
    link_to_path "${PEARL_PKGDIR}/bin/cmd"
}

function post_update(){
    post_install
}

function pre_remove(){
    unlink_from_path "${PEARL_PKGDIR}/bin/cmd"
}
