
unset PEARL_ROOT CMD_CONFIG_DIR
OLD_PWD=$PWD

function pearlSetUp() {
    export PEARL_ROOT=$(TMPDIR=/tmp mktemp -d -t pearl-test-root.XXXXXXX)
    git clone --quiet https://github.com/pearl-core/pearl.git $PEARL_ROOT
}

function pearlTearDown(){
    rm -rf $PEARL_ROOT
    unset PEARL_ROOT
}

function cmdSetUp(){
    export CMD_CONFIG_DIR=$(TMPDIR=/tmp mktemp -d -t cmd-config.XXXXXXX)
    export CMD_ROOT=$(dirname $0)/../../
}

function cmdTearDown(){
    cd $OLD_PWD
    rm -rf $CMD_CONFIG_DIR
    unset CMD_CONFIG_DIR CMD_ROOT
}

function setUpUnitTests(){
    OUTPUT_DIR="${SHUNIT_TMPDIR}/output"
    mkdir "${OUTPUT_DIR}"
    STDOUTF="${OUTPUT_DIR}/stdout"
    STDERRF="${OUTPUT_DIR}/stderr"
}

function assertCommandSuccess(){
    $(set -e
      "$@" > $STDOUTF 2> $STDERRF
    )
    assertTrue "The command $1 did not return 0 exit status" $?
}

function assertCommandFail(){
    $(set -e
      "$@" > $STDOUTF 2> $STDERRF
    )
    assertFalse "The command $1 returned 0 exit status" $?
}

# $1: expected exit status
# $2-: The command under test
function assertCommandFailOnStatus(){
    local status=$1
    shift
    $(set -e
      "$@" > $STDOUTF 2> $STDERRF
    )
    assertEquals $status $?
}
