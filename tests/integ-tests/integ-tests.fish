#!/usr/bin/fish

if [ -z $argv[1] ]
    echo "ERROR: To run the integ tests you must specify the Pearl location."
    echo "For instance: $0 ~/.local/share/pearl"
    exit 33
end

set -x PEARL_ROOT $argv[1]

# From here is where you can add the integ tests for your packages

if [ ! -d $PEARL_HOME/packages/default/test ]
    echo "The package test does not exist after install"
    exit 1
end

source ./tests/integ-tests/integ-tests-common.sh
