unset CMD_VARDIR

function cmdSetUp(){
    export CMD_VARDIR=$(TMPDIR=/tmp mktemp -d -t cmd-config.XXXXXXX)
    export PKG_ROOT=$(dirname $0)/../../
    # Create a second fake path in cmds2
    echo "$CMD_VARDIR/cmds" > $CMD_VARDIR/cmds_path
    echo "$CMD_VARDIR/cmds2" >> $CMD_VARDIR/cmds_path
    mkdir -p $CMD_VARDIR/cmds
    mkdir -p $CMD_VARDIR/cmds2/myns2
    # Add existing commands in cmds
    echo "echo mycommand" > $CMD_VARDIR/cmds2/myns2/myalias2
    chmod +x $CMD_VARDIR/cmds2/myns2/myalias2
    mkdir -p $CMD_VARDIR/bin
}

function cmdTearDown(){
    rm -rf $CMD_VARDIR
    unset CMD_VARDIR PKG_ROOT
}
