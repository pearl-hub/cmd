PATH=$PATH:$PEARL_PKGDIR/bin

# Trap USR2 signal
trap "$PEARL_TEMPORARY/new_cmd" USR2