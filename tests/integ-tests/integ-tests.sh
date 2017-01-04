#!/usr/bin/env bash

set -e

source "$HOME/.bashrc"

pearl install test

source ./tests/integ-tests/integ-tests-common.sh
