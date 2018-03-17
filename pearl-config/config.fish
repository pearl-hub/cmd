set -x CMD_USER_DIR $PEARL_PKGVARDIR

switch $CMD_PATH
case "*$PEARL_PKGVARDIR*"
    echo > /dev/null
case '*'
    set -x CMD_PATH "$PEARL_PKGVARDIR:$CMD_PATH"
end

# vim: ft=sh
