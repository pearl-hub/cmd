#!/usr/bin/fish

source $HOME/.config/fish/config.fish

pearl install test
# Fish trap may not work from time to time.
# Forcing the sourcing here:
source $HOME/.config/fish/config.fish

source ./tests/integ-tests/integ-tests-common.sh

