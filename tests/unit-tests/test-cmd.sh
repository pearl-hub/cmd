#!/bin/bash
source "$(dirname $0)/../utils/utils.sh"

pearlSetUp
cmdSetUp
CMD_LOCATION="$(dirname $0)/../.."
source $CMD_LOCATION/bin/cmd -h &> /dev/null

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function oneTimeTearDown(){
    cmdTearDown
    pearlTearDown
}

function setUp(){
    :
}

function tearDown(){
    :
}

function cli_wrap(){
    parse_arguments "$@"
    check_cli
    execute_operation
}

function add_command(){
    echo "add_command $@"
}

function remove_command(){
    echo "remove_command $@"
}

function execute_command(){
    echo "execute_command $@"
}

function list_command(){
    echo "list_command $@"
}

function print_command(){
    echo "print_command $@"
}

function test_help(){
    assertCommandSuccess cli_wrap -h
    cat $STDOUTF | grep -q "cmd"
    assertEquals 0 $?
    assertCommandSuccess cli_wrap --help
    cat $STDOUTF | grep -q "cmd"
    assertEquals 0 $?
    assertCommandSuccess cli_wrap help
    cat $STDOUTF | grep -q "cmd"
    assertEquals 0 $?
    assertCommandSuccess cli_wrap h
    cat $STDOUTF | grep -q "cmd"
    assertEquals 0 $?
}

function test_cmd_no_pearl_root_defined(){
    OLD_PEARL_ROOT=$PEARL_ROOT
    unset PEARL_ROOT
    assertCommandFailOnStatus 1 source $CMD_LOCATION/bin/cmd -h
    PEARL_ROOT=$OLD_PEARL_ROOT
}

function test_cmd_no_pearl_root_directory(){
    OLD_PEARL_ROOT=$PEARL_ROOT
    PEARL_ROOT="not-a-directory"
    assertCommandFailOnStatus 2 source $CMD_LOCATION/bin/cmd -h
    PEARL_ROOT=$OLD_PEARL_ROOT
}

function test_cmd_no_cmd_config_defined(){
    OLD_CMD_CONFIG_DIR=$CMD_CONFIG_DIR
    unset CMD_CONFIG_DIR
    assertCommandFailOnStatus 1 source $CMD_LOCATION/bin/cmd -h
    CMD_CONFIG_DIR=$OLD_CMD_CONFIG_DIR
}

function test_cmd_no_cmd_config_directory(){
    OLD_CMD_CONFIG_DIR=$CMD_CONFIG_DIR
    CMD_CONFIG_DIR="not-a-directory"
    assertCommandFailOnStatus 2 source $CMD_LOCATION/bin/cmd -h
    CMD_CONFIG_DIR=$OLD_CMD_CONFIG_DIR
}

function test_cmd_add(){
    assertCommandSuccess cli_wrap add myalias
    assertEquals "$(echo -e "add_command myalias")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap a myalias
    assertEquals "$(echo -e "add_command myalias")" "$(cat $STDOUTF)"
}

function test_cmd_remove(){
    assertCommandSuccess cli_wrap remove myalias
    assertEquals "$(echo -e "remove_command myalias")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap r myalias
    assertEquals "$(echo -e "remove_command myalias")" "$(cat $STDOUTF)"
}

function test_cmd_execute(){
    assertCommandSuccess cli_wrap execute myalias
    assertEquals "$(echo -e "execute_command myalias")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap e myalias
    assertEquals "$(echo -e "execute_command myalias")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap e myalias var1=abc
    assertEquals "$(echo -e "execute_command myalias var1=abc")" "$(cat $STDOUTF)"
}

function test_cmd_list(){
    assertCommandSuccess cli_wrap list
    assertEquals "$(echo -e "list_command ")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap l
    assertEquals "$(echo -e "list_command ")" "$(cat $STDOUTF)"
}

function test_cmd_print(){
    assertCommandSuccess cli_wrap print myalias
    assertEquals "$(echo -e "print_command myalias")" "$(cat $STDOUTF)"

    assertCommandSuccess cli_wrap p myalias
    assertEquals "$(echo -e "print_command myalias")" "$(cat $STDOUTF)"
}

function test_check_cli(){
    assertCommandFail cli_wrap
    assertCommandFail cli_wrap -h add
    assertCommandFail cli_wrap wrong_arg
    assertCommandFail cli_wrap list wrong_arg
    assertCommandFail cli_wrap -h wrong_arg
    assertCommandFail cli_wrap p alias1 alias2
    assertCommandFail cli_wrap r alias1 alias2
    assertCommandFail cli_wrap a alias1 alias2
}

source $(dirname $0)/../utils/shunit2
