if [[ $PATH != *"${PEARL_PKGDIR}/bin"* ]]
then
    PATH=$PATH:$PEARL_PKGDIR/bin
fi

# Trap USR2 signal
trap "$PEARL_TEMPORARY/new_cmd" USR2
