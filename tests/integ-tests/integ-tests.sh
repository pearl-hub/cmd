#!/bin/bash

set -e

source "$HOME/.bashrc"

pearl install test

source ./tests/integ-tests/integ-tests-common.sh
