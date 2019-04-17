# This module contains all functionalities needed for
# handling the cmd core.
#
# Dependencies:
# - [buava] $PKG_ROOT/buava/lib/utils.sh
#
# vim: ft=sh


CAT=cat
CHMOD=chmod
LS=ls
LN=ln
MKDIR=mkdir
RM=rm

apply "${CMD_VARDIR}/cmds" "${CMD_VARDIR}/cmds_path"

#######################################
# Add/Update a new command/script.
#
# Globals:
#   EDITOR (RO?)        :  The editor to use for adding/updating.
#   CAT (RO)            :  The cat command to use as fallback.
#   CMD_VARDIR (RO)     :  The directory containing the commands/scripts.
# Arguments:
#   alias ($1)          :  The command alias to add/update.
# Returns:
#   0
#   $NULL_EXCEPTION     : Null alias.
# Output:
#   The message in case of errors.
#######################################
function add_command() {
    local alias="$1"
    check_not_null $alias
    local file="$CMD_VARDIR/cmds/$alias"
    $MKDIR -p "$(dirname "$file")"
    if [[ -z "$EDITOR" ]]; then
        info "Write the script below and press Cntrl-c on a new line to save it:"
        $CAT > "$file"
    else
        $EDITOR "$file"
    fi

    $CHMOD +x $file
    filename=${alias//\//-}
    link_to "$file" "$CMD_VARDIR/bin/$filename"
}

#######################################
# Remove an existing command/script.
#
# Globals:
#   RM (RO)             :  The rm command.
#   CMD_VARDIR (RO)     :  The directory containing the commands/scripts.
# Arguments:
#   alias ($1)          :  The command alias to remove.
# Returns:
#   0                   : Successful removal.
#   3                   : The alias does not exist.
#   $NULL_EXCEPTION     : Null alias.
# Output:
#   The message in case of errors.
#######################################
function remove_command() {
    local alias="$1"
    check_not_null $alias

    [[ ! -e $CMD_VARDIR/cmds/$alias ]] && \
        die_on_status 3 "The alias does not exist."

    filename=${alias//\//-}
    bin_file="$CMD_VARDIR/bin/$filename"
    cmds_file="$CMD_VARDIR/cmds/$alias"
    unlink_from "$cmds_file" "$bin_file"

    cd "$CMD_VARDIR/cmds"
    $RM -r "$alias"
}

#######################################
# Execute an existing command/script.
#
# Globals:
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#   alias ($1)          :  The command alias to execute.
#   variables ($2-?)    :  The variables to use in the script.
# Returns:
#   0                   : Successful executiong.
#   1                   : Permission to execute not accepted.
#   3                   : The alias does not exist.
#   $NULL_EXCEPTION     : Null alias.
# Output:
#   The command to execute.
#   The message in case of errors.
#######################################
function execute_command() {
    local alias="$1"
    check_not_null $alias
    shift

    local cmd_file=""
    while read cmd_dir; do
        [[ -f $cmd_dir/$alias ]] && cmd_file="$cmd_dir/$alias"
    done < $CMD_VARDIR/cmds_path

    [[ -z $cmd_file ]] && \
        die_on_status 3 "The alias does not exist."

    show_command $alias
    ask "Are you sure to run the script?" "N" && \
        {
            for var in "$@"
            do
                [[ $var != *"="* ]] && break
                eval "export $var"
                shift
            done
            $cmd_file "$@"
        }
}

#######################################
# Include all the command from the given directory.
# All the scripts should be executable and in either the same level of the
# given directory or in a nested directory. This function will not look for
# scripts that are in multiple nested directories, only one level is allowed.
#
# Globals:
#   PWD (RO)            : The pwd.
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#   directory ($1)      : The directory containing the command/scripts.
# Returns:
#   0                   : Successful execution.
#   110                 : The directory does not exist.
#   $NULL_EXCEPTION     : Null directory.
# Output:
#   The message in case of errors.
#######################################
function include_command() {
    local directory="$1"
    check_not_null $directory
    local full_path=$(readlink -f "$directory")

    [[ -d $full_path ]] || die_on_status 110 "$directory: no such directory"

    local old_pwd="${PWD}"
    cd "$directory"
    for alias in * */*
    do
        if [[ -x $alias && -f $alias ]]
        then
            filename="${alias//\//-}"
            link_to "$full_path/$alias" "$CMD_VARDIR/bin/$filename"
        fi
    done
    cd "${old_pwd}"

    apply "$full_path" $CMD_VARDIR/cmds_path
}

#######################################
# Exclude all the command from the given directory
#
# Globals:
#   PWD (RO)            : The pwd.
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#   directory ($1)      : The directory containing the command/scripts.
# Returns:
#   0                   : Successful execution.
#   110                 : The directory does not exist.
#   $NULL_EXCEPTION     : Null directory.
# Output:
#   The message in case of errors.
#######################################
function exclude_command() {
    local directory="$1"
    check_not_null $directory
    local full_path=$(readlink -f "$directory")

    [[ -d $full_path ]] || die_on_status 110 "$directory: no such directory"

    local old_pwd="${PWD}"
    cd "$directory"
    for alias in * */*
    do
        if [[ -x $alias && -f $alias ]]
        then
            filename="${alias//\//-}"
            unlink_from "$full_path/$alias" "$CMD_VARDIR/bin/$filename"
        fi
    done
    cd "${old_pwd}"

    unapply "$full_path" $CMD_VARDIR/cmds_path
}

#######################################
# Show the paths of the included directories.
#
# Globals:
#   CAT (RO)            :  The cat command.
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#  None
# Returns:
#   0                   : Successful execution.
# Output:
#   The list of paths.
#######################################
function paths_command() {
    $CAT $CMD_VARDIR/cmds_path
}

#######################################
# Show an existing command/script.
#
# Globals:
#   CAT (RO)            :  The cat command.
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#   alias ($1)          :  The command alias to show.
# Returns:
#   0                   : Successful execution.
#   3                   : The alias does not exist.
#   $NULL_EXCEPTION     : Null alias.
# Output:
#   The command to execute
#   The message in case of errors.
#######################################
function show_command() {
    local alias="$1"
    check_not_null $alias

    local cmd_file=""
    while read cmd_dir; do
        [[ -f $cmd_dir/$alias ]] && cmd_file="$cmd_dir/$alias"
    done < $CMD_VARDIR/cmds_path

    [[ -z $cmd_file ]] && \
        die_on_status 3 "The alias does not exist."

    $CAT "$cmd_file"
}

#######################################
# List all the available commands/scripts.
#
# Globals:
#   LS (RO)            :  The ls command.
#   CMD_VARDIR (RO)     : The directory containing the commands/scripts.
# Arguments:
#   None
# Returns:
#   0                  : Successful listing.
# Output:
#   The list of commands/scripts.
#######################################
function list_command() {
    while read cmd_dir; do
        if [[ -d $cmd_dir ]]
        then
            cd "$cmd_dir"
            $LS -R
        fi
    done < $CMD_VARDIR/cmds_path

    return 0
}
