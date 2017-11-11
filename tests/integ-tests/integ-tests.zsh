#!/usr/bin/env zsh

set -e

source "$HOME/.zshrc"

pearl install test

source ./tests/integ-tests/integ-tests-common.sh
