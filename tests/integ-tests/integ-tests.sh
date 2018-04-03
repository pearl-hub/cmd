#!/usr/bin/env bash

set -e

source "$HOME/.bashrc"

pearl install test

set -x

source ./tests/integ-tests/integ-tests-common.sh
