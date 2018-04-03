export CMD_VARDIR="$PEARL_PKGVARDIR"

if [[ $CMD_PATH != *"$CMD_VARDIR/cmds"* ]]
then
    export CMD_PATH="$CMD_VARDIR/cmds:$CMD_PATH"
fi

export PATH="$PATH:$CMD_VARDIR/bin"
