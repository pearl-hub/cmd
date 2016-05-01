if not contains $PEARL_PKGDIR/bin $PATH
    set PATH $PATH $PEARL_PKGDIR/bin
end

# Trap USR2 signal
trap "$PEARL_TEMPORARY/new_cmd" USR2

# vim: ft=sh
