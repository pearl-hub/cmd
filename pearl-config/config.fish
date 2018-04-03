set -x CMD_VARDIR $PEARL_PKGVARDIR

switch $CMD_PATH
case "*$PEARL_PKGVARDIR/cmds*"
    echo > /dev/null
case '*'
    set -x CMD_PATH "$CMD_VARDIR/cmds:$CMD_PATH"
end

set -x PATH $PATH $CMD_VARDIR/bin
# vim: ft=sh
