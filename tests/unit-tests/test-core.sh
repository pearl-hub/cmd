#!/usr/bin/env bash
PKG_LOCATION="$(dirname $0)/../.."
source "$PKG_LOCATION/tests/bunit/utils/utils.sh"
source "$PKG_LOCATION/tests/test-utils/utils.sh"
source "$PKG_LOCATION/tests/utils/utils.sh"

pearlSetUp
source $PKG_LOCATION/buava/lib/utils.sh

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
    source "$PKG_LOCATION/lib/core.sh"
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
    assertEquals "this is my command" "$(cat $CMD_VARDIR/cmds/myalias)"
    assertEquals "this is my command" "$(cat $CMD_VARDIR/bin/myalias)"
    assertTrue "File is not executable" "[[ -x $CMD_VARDIR/bin/myalias ]]"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}

function test_add_command_with_editor(){
    OLD_EDITOR=$EDITOR
    EDITOR=touch
    OLD_CAT=$CAT
    unset CAT
    assertCommandSuccess add_command "myalias"
    assertEquals "" "$(cat $CMD_VARDIR/cmds/myalias)"
    assertEquals "" "$(cat $CMD_VARDIR/bin/myalias)"
    assertTrue "File is not executable" "[[ -x $CMD_VARDIR/bin/myalias ]]"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}

function test_add_command_with_namespace(){
    OLD_EDITOR=$EDITOR
    unset EDITOR
    OLD_CAT=$CAT
    CAT="echo this is my command"
    assertCommandSuccess add_command "myns/myalias"
    assertEquals "this is my command" "$(cat $CMD_VARDIR/cmds/myns/myalias)"
    assertEquals "this is my command" "$(cat $CMD_VARDIR/bin/myns-myalias)"
    assertTrue "File is not executable" "[[ -x $CMD_VARDIR/bin/myns-myalias ]]"
    EDITOR=$OLD_EDITOR
    CAT=$OLD_CAT
}


function test_add_command_alias_already_exist(){
    echo "previous command" > $CMD_VARDIR/cmds/myalias
    test_add_command_without_editor
}

function test_remove_command_null_alias(){
    assertCommandFailOnStatus 11 remove_command
}

function test_remove_command(){
    touch $CMD_VARDIR/cmds/myalias
    ln -s $CMD_VARDIR/cmds/myalias $CMD_VARDIR/bin/myalias
    assertCommandSuccess remove_command "myalias"
    assertTrue "File still exists" "[[ ! -e $CMD_VARDIR/cmds/myalias ]]"
    assertTrue "File still exists" "[[ ! -e $CMD_VARDIR/bin/myalias ]]"
}

function test_remove_command_with_namespace(){
    mkdir -p $CMD_VARDIR/cmds/myns
    touch $CMD_VARDIR/cmds/myns/myalias
    ln -s $CMD_VARDIR/cmds/myns/myalias $CMD_VARDIR/bin/myalias
    assertCommandSuccess remove_command "myns/myalias"
    assertTrue "File still exists" "[[ ! -e $CMD_VARDIR/cmds/myns/myalias ]]"
    assertTrue "File still exists" "[[ ! -e $CMD_VARDIR/bin/myalias ]]"
}

function test_remove_command_alias_does_not_exist(){
    assertCommandFailOnStatus 3 remove_command "myalias"
}

function test_show_command_null_alias(){
    assertCommandFailOnStatus 11 show_command
}

function test_show_command(){
    echo "mycommand" > $CMD_VARDIR/cmds/myalias
    assertCommandSuccess show_command "myalias"
    assertEquals "mycommand" "$(cat $STDOUTF)"
}

function test_show_command_with_namespace(){
    mkdir -p $CMD_VARDIR/cmds/myns
    echo "mycommand" > $CMD_VARDIR/cmds/myns/myalias
    assertCommandSuccess show_command "myns/myalias"
    assertEquals "mycommand" "$(cat $STDOUTF)"
}

function test_show_command_alias_does_not_exist(){
    assertCommandFailOnStatus 3 show_command "myalias"
}

function test_include_command_null_alias(){
    assertCommandFailOnStatus 11 include_command
}

function test_include_command_not_existing_directory(){
    assertCommandFailOnStatus 110 include_command "not-a-directory"
}

function test_include_command_empty_directory(){
    mkdir -p $CMD_VARDIR/cmds3
    assertCommandSuccess include_command $CMD_VARDIR/cmds3
    assertFalse "Bin files should not exist" "[[ "$(ls -A $CMD_VARDIR/bin/)" ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds3\n$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_include_command_one_script(){
    mkdir -p $CMD_VARDIR/cmds3
    touch $CMD_VARDIR/cmds3/one-script
    chmod +x $CMD_VARDIR/cmds3/one-script
    assertCommandSuccess include_command $CMD_VARDIR/cmds3

    assertTrue "File does not exist" "[[ -e $CMD_VARDIR/bin/one-script ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds3\n$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_include_command_one_nested_script(){
    mkdir -p $CMD_VARDIR/cmds3/myns
    touch $CMD_VARDIR/cmds3/myns/one-script
    chmod +x $CMD_VARDIR/cmds3/myns/one-script
    assertCommandSuccess include_command $CMD_VARDIR/cmds3

    assertTrue "File does not exist" "[[ -e $CMD_VARDIR/bin/myns-one-script ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds3\n$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_include_command_one_multiple_nested_script(){
    mkdir -p $CMD_VARDIR/cmds3/myns/myns2
    touch $CMD_VARDIR/cmds3/myns/myns2/one-script
    chmod +x $CMD_VARDIR/cmds3/myns/myns2/one-script
    assertCommandSuccess include_command $CMD_VARDIR/cmds3

    assertFalse "Bin files should not exist" "[[ "$(ls -A $CMD_VARDIR/bin/)" ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds3\n$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_exclude_command_null_alias(){
    assertCommandFailOnStatus 11 exclude_command
}

function test_exclude_command_not_existing_directory(){
    assertCommandFailOnStatus 110 exclude_command "not-a-directory"
}

function test_exclude_command_empty_directory(){
    mkdir -p $CMD_VARDIR/cmds3
    echo "$CMD_VARDIR/cmds3" >> $CMD_VARDIR/cmds_path

    assertCommandSuccess exclude_command $CMD_VARDIR/cmds3

    assertFalse "Bin files should not exist" "[[ "$(ls -A $CMD_VARDIR/bin/)" ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_exclude_command_one_script(){
    mkdir -p $CMD_VARDIR/cmds3
    echo "$CMD_VARDIR/cmds3" >> $CMD_VARDIR/cmds_path
    touch $CMD_VARDIR/cmds3/one-script
    chmod +x $CMD_VARDIR/cmds3/one-script
    ln -s $CMD_VARDIR/cmds3/one-script $CMD_VARDIR/bin/one-script

    assertCommandSuccess exclude_command $CMD_VARDIR/cmds3

    assertFalse "File exists" "[[ -e $CMD_VARDIR/bin/one-script ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_exclude_command_one_nested_script(){
    mkdir -p $CMD_VARDIR/cmds3/myns
    echo "$CMD_VARDIR/cmds3" >> $CMD_VARDIR/cmds_path
    touch $CMD_VARDIR/cmds3/myns/one-script
    chmod +x $CMD_VARDIR/cmds3/myns/one-script
    ln -s $CMD_VARDIR/cmds3/myns/one-script $CMD_VARDIR/bin/myns-one-script

    assertCommandSuccess exclude_command $CMD_VARDIR/cmds3

    assertFalse "File exists" "[[ -e $CMD_VARDIR/bin/myns-one-script ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_exclude_command_one_multiple_nested_script(){
    mkdir -p $CMD_VARDIR/cmds3/myns/myns2
    echo "$CMD_VARDIR/cmds3" >> $CMD_VARDIR/cmds_path
    touch $CMD_VARDIR/cmds3/myns/myns2/one-script
    chmod +x $CMD_VARDIR/cmds3/myns/myns2/one-script

    assertCommandSuccess exclude_command $CMD_VARDIR/cmds3

    assertFalse "Bin files should not exist" "[[ "$(ls -A $CMD_VARDIR/bin/)" ]]"
    assertEquals "$(echo -e "$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $CMD_VARDIR/cmds_path)"
}

function test_paths_command(){
    assertCommandSuccess paths_command
    assertEquals "$(echo -e "$CMD_VARDIR/cmds\n$CMD_VARDIR/cmds2")" "$(cat $STDOUTF)"
}

function test_list_command(){
    touch $CMD_VARDIR/cmds/myalias
    touch $CMD_VARDIR/cmds/myalias2
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:\nmyalias\nmyalias2\n.:\nmyns2\n\n./myns2:\nmyalias2")" "$(cat $STDOUTF)"
}

function test_list_command_with_namespace(){
    mkdir -p $CMD_VARDIR/cmds/myns
    touch $CMD_VARDIR/cmds/myns/myalias
    touch $CMD_VARDIR/cmds/myns/myalias2
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:\nmyns\n\n./myns:\nmyalias\nmyalias2\n.:\nmyns2\n\n./myns2:\nmyalias2")" "$(cat $STDOUTF)"
}

function test_list_command_empty_dir(){
    assertCommandSuccess list_command
    assertEquals "$(echo -e ".:\n.:\nmyns2\n\n./myns2:\nmyalias2")" "$(cat $STDOUTF)"
}

function test_execute_command_null_alias(){
    assertCommandFailOnStatus 11 execute_command
}

function test_execute_command(){
    ask() {
        return 0
    }
    echo "echo executed command" > $CMD_VARDIR/cmds/myalias
    chmod +x $CMD_VARDIR/cmds/myalias
    assertCommandSuccess execute_command "myalias"
    assertEquals "$(echo -e "echo executed command\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_with_namespace(){
    ask() {
        return 0
    }
    mkdir -p $CMD_VARDIR/cmds/myns
    echo "echo executed command" > $CMD_VARDIR/cmds/myns/myalias
    chmod +x $CMD_VARDIR/cmds/myns/myalias
    assertCommandSuccess execute_command "myns/myalias"
    assertEquals "$(echo -e "echo executed command\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_external_command(){
    ask() {
        return 0
    }
    assertCommandSuccess execute_command "myns2/myalias2"
    assertEquals "$(echo -e "echo mycommand\nmycommand")" "$(cat $STDOUTF)"
}

function test_execute_command_with_variables(){
    ask() {
        return 0
    }
    echo "echo executed command \$var1" > $CMD_VARDIR/cmds/myalias
    chmod +x $CMD_VARDIR/cmds/myalias
    assertCommandSuccess execute_command myalias "var1='abc -def'"
    assertEquals "$(echo -e "echo executed command \$var1\nexecuted command abc -def")" "$(cat $STDOUTF)"
}

function test_execute_command_with_special_variables(){
    ask() {
        return 0
    }
    echo "echo executed command \$opts \$2" > $CMD_VARDIR/cmds/myalias
    chmod +x $CMD_VARDIR/cmds/myalias
    assertCommandSuccess execute_command myalias opts="super" sonic 'and fantastic'
    assertEquals "$(echo -e "echo executed command \$opts \$2\nexecuted command super and fantastic")" "$(cat $STDOUTF)"
}

function test_execute_command_with_variables_not_assigned(){
    ask() {
        return 0
    }
    echo "echo executed command \$var1" > $CMD_VARDIR/cmds/myalias
    chmod +x $CMD_VARDIR/cmds/myalias
    assertCommandSuccess execute_command myalias
    assertEquals "$(echo -e "echo executed command \$var1\nexecuted command")" "$(cat $STDOUTF)"
}

function test_execute_command_ask_no(){
    ask() {
        return 1
    }
    echo "echo executed command" > $CMD_VARDIR/cmds/myalias
    chmod +x $CMD_VARDIR/cmds/myalias
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
