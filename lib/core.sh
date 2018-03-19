# This module contains all functionalities needed for
# handling the cmd core.
#
# Dependencies:
# - [buava] $PKG_ROOT/buava/lib/utils.sh
#
# vim: ft=sh


CAT=cat
RM=rm
LS=ls
MKDIR=mkdir

#######################################
# Add/Update a new command/script.
#
# Globals:
#   EDITOR (RO?)        :  The editor to use for adding/updating.
#   CAT (RO)            :  The cat command to use as fallback.
#   CMD_USER_DIR (RO)   :  The directory containing the commands/scripts.
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
    local file=$CMD_USER_DIR/$alias
    $MKDIR -p "$(dirname "$file")"
    if [[ -z "$EDITOR" ]]; then
        info "Write the script below and press Cntrl-c on a new line to save it:"
        $CAT > "$file"
    else
        $EDITOR "$file"
    fi
}

#######################################
# Remove an existing command/script.
#
# Globals:
#   RM (RO)             :  The rm command.
#   CMD_USER_DIR (RO)   :  The directory containing the commands/scripts.
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
    [[ ! -e $CMD_USER_DIR/$alias ]] && \
        die_on_status 3 "The alias does not exist."
    cd "$CMD_USER_DIR"
    $RM -r "$alias"
}

#######################################
# Execute an existing command/script.
#
# Globals:
#   CMD_PATH (RO)       :  The directories (colon separated) containing
#                          the commands/scripts.
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
    local IFS=$':'
    for cmd_dir in $CMD_PATH
    do
        [[ -f $cmd_dir/$alias ]] && cmd_file="$cmd_dir/$alias"
    done
    unset IFS

    [[ -z $cmd_file ]] && \
        die_on_status 3 "The alias does not exist."

    print_command $alias
    ask "Are you sure to run the script?" "N" && \
        {
            for var in "$@"
            do
                [[ $var != *"="* ]] && break
                eval "$var"
                shift
            done
            CMD_SCRIPT_FILE=$cmd_file
            source "$cmd_file"
        }
}

#######################################
# Print an existing command/script.
#
# Globals:
#   CAT (RO)            :  The cat command.
#   CMD_PATH (RO)       :  The directories (colon separated) containing
#                          the commands/scripts.
# Arguments:
#   alias ($1)          :  The command alias to print.
# Returns:
#   0                   : Successful executiong.
#   3                   : The alias does not exist.
#   $NULL_EXCEPTION     : Null alias.
# Output:
#   The command to execute
#   The message in case of errors.
#######################################
function print_command() {
    local alias="$1"
    check_not_null $alias

    local cmd_file=""
    local IFS=$':'
    for cmd_dir in $CMD_PATH
    do
        [[ -f $cmd_dir/$alias ]] && cmd_file="$cmd_dir/$alias"
    done
    unset IFS

    [[ -z $cmd_file ]] && \
        die_on_status 3 "The alias does not exist."

    $CAT "$cmd_file"
}

#######################################
# List all the availble commands/scripts.
#
# Globals:
#   LS (RO)            :  The ls command.
#   CMD_PATH (RO)      :  The directories (colon separated) containing
#                          the commands/scripts.
# Arguments:
#   None
# Returns:
#   0                  : Successful listing.
# Output:
#   The list of commands/scripts.
#######################################
function list_command() {
    local IFS=$':'
    for cmd_dir in $CMD_PATH
    do
        if [[ -d $cmd_dir ]]
        then
            cd "$cmd_dir"
            $LS -R
        fi
    done
    unset IFS
}
