unset CMD_CONFIG_DIR

function cmdSetUp(){
    export CMD_CONFIG_DIR=$(TMPDIR=/tmp mktemp -d -t cmd-config.XXXXXXX)
    export PKG_ROOT=$(dirname $0)/../../
}

function cmdTearDown(){
    rm -rf $CMD_CONFIG_DIR
    unset CMD_CONFIG_DIR PKG_ROOT
}
