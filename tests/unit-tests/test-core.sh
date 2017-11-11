#!/usr/bin/env bash
PKG_LOCATION="$(dirname $0)/../.."
source "$PKG_LOCATION/tests/bunit/utils/utils.sh"
source "$PKG_LOCATION/tests/test-utils/utils.sh"
source "$PKG_LOCATION/tests/utils/utils.sh"

pearlSetUp
source $PKG_LOCATION/buava/lib/utils.sh
source "$PKG_LOCATION/lib/core.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function oneTimeTearDown(){
    pearlTearDown
}

function setUp(){
    cmdSetUp
}

function tearDown(){
    cmdTearDown
}

function test_add_command_null_alias(){
    assertCommandFailOnStatus 11 add_command
}

function test_add_command_without_editor(){
    OLD_EDITOR=$EDITOR
    unset EDITOR
    OLD_CAT=$CAT
    CAT="echo this is my command"
    assertCommandSuccess add_command "myalias"
    assertEquals "this is my command" "$(cat $CMD_CONFIG_DIR/myalias)"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}

function test_add_command_with_editor(){
    OLD_EDITOR=$EDITOR
    EDITOR=touch
    OLD_CAT=$CAT
    unset CAT
    assertCommandSuccess add_command "myalias"
    assertEquals "" "$(cat $CMD_CONFIG_DIR/myalias)"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}

function test_add_command_with_namespace(){
    OLD_EDITOR=$EDITOR
    unset EDITOR
    OLD_CAT=$CAT
    CAT="echo this is my command"
    assertCommandSuccess add_command "myns/myalias"
    assertEquals "this is my command" "$(cat $CMD_CONFIG_DIR/myns/myalias)"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}


function test_add_command_alias_already_exist(){
    echo "previous command" > $CMD_CONFIG_DIR/myalias
    test_add_command_without_editor
}

function test_remove_command_null_alias(){
    assertCommandFailOnStatus 11 remove_command
}

function test_remove_command(){
    touch $CMD_CONFIG_DIR/myalias
    assertCommandSuccess remove_command "myalias"
    assertCommandFailOnStatus 2 ls $CMD_CONFIG_DIR/myalias
}

function test_remove_command_with_namespace(){
    mkdir -p $CMD_CONFIG_DIR/myns
    touch $CMD_CONFIG_DIR/myns/myalias
    assertCommandSuccess remove_command "myns/myalias"
    assertCommandFailOnStatus 2 ls $CMD_CONFIG_DIR/myns/myalias
}

function test_remove_command_alias_does_not_exist(){
    assertCommandFailOnStatus 3 remove_command "myalias"
}

function test_print_command_null_alias(){
    assertCommandFailOnStatus 11 print_command
}

function test_print_command(){
    echo "mycommand" > $CMD_CONFIG_DIR/myalias
    assertCommandSuccess print_command "myalias"
    assertEquals "mycommand" "$(cat $STDOUTF)"
}

function test_print_command_with_namespace(){
    mkdir -p $CMD_CONFIG_DIR/myns
    echo "mycommand" > $CMD_CONFIG_DIR/myns/myalias
    assertCommandSuccess print_command "myns/myalias"
    assertEquals "mycommand" "$(cat $STDOUTF)"
}

function test_print_command_alias_does_not_exist(){
    assertCommandFailOnStatus 3 print_command "myalias"
}

function test_list_command(){
    touch $CMD_CONFIG_DIR/myalias
    touch $CMD_CONFIG_DIR/myalias2
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:\nmyalias\nmyalias2")" "$(cat $STDOUTF)"
}

function test_list_command_with_namespace(){
    mkdir -p $CMD_CONFIG_DIR/myns
    touch $CMD_CONFIG_DIR/myns/myalias
    touch $CMD_CONFIG_DIR/myns/myalias2
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:\nmyns\n\n./myns:\nmyalias\nmyalias2")" "$(cat $STDOUTF)"
}

function test_list_command_empty_dir(){
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:")" "$(cat $STDOUTF)"
}

function test_execute_command_null_alias(){
    assertCommandFailOnStatus 11 execute_command
}

function test_execute_command(){
    ask() {
        return 0
    }
    echo "echo executed command" > $CMD_CONFIG_DIR/myalias
    assertCommandSuccess execute_command "myalias"
    assertEquals "$(echo -e "echo executed command\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_with_namespace(){
    ask() {
        return 0
    }
    mkdir -p $CMD_CONFIG_DIR/myns
    echo "echo executed command" > $CMD_CONFIG_DIR/myns/myalias
    assertCommandSuccess execute_command "myns/myalias"
    assertEquals "$(echo -e "echo executed command\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_with_variables(){
    ask() {
        return 0
    }
    echo "echo executed command \$var1" > $CMD_CONFIG_DIR/myalias
    assertCommandSuccess execute_command myalias "var1='abc -def'"
    assertEquals "$(echo -e "echo executed command \$var1\nexecuted command abc -def")" "$(cat $STDOUTF)"
}

function test_execute_command_with_special_variables(){
    ask() {
        return 0
    }
    echo "echo executed command \$opts \$@" > $CMD_CONFIG_DIR/myalias
    assertCommandSuccess execute_command myalias opts="super" sonic
    assertEquals "$(echo -e "echo executed command \$opts \$@\nexecuted command super sonic")" "$(cat $STDOUTF)"
}

function test_execute_command_with_variables_not_assigned(){
    ask() {
        return 0
    }
    echo "echo executed command \$var1" > $CMD_CONFIG_DIR/myalias
    assertCommandSuccess execute_command myalias
    assertEquals "$(echo -e "echo executed command \$var1\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_ask_no(){
    ask() {
        return 1
    }
    echo "echo executed command" > $CMD_CONFIG_DIR/myalias
    assertCommandFailOnStatus 1 execute_command "myalias"
    assertEquals "$(echo -e "echo executed command")" "$(cat $STDOUTF)"
}

function test_execute_command_alias_does_not_exist(){
    assertCommandFailOnStatus 3 execute_command "myalias"
}

function test_execute_command_alias_does_not_exist_with_namespace(){
    assertCommandFailOnStatus 3 execute_command "myns/myalias"
}

source $PKG_LOCATION/tests/bunit/utils/shunit2
