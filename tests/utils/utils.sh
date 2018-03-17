unset CMD_USER_DIR

function cmdSetUp(){
    export CMD_USER_DIR=$(TMPDIR=/tmp mktemp -d -t cmd-config.XXXXXXX)
    export PKG_ROOT=$(dirname $0)/../../
    export CMD_PATH="$CMD_USER_DIR"
}

function cmdTearDown(){
    rm -rf $CMD_USER_DIR
    unset CMD_USER_DIR PKG_ROOT CMD_PATH
}
