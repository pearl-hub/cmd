#!/bin/bash

cmd help

# Test user defined commands
export EDITOR="eval echo ls -l >"
cmd add myalias

cmd list
cmd show myalias
echo y | cmd execute myalias
# Alternative execution:
myalias

cmd remove myalias

# Test third-party commands
mkdir -p $HOME/cmds
echo "pwd" > $HOME/cmds/myalias2
chmod +x $HOME/cmds/myalias2
cmd include $HOME/cmds

cmd list
cmd show myalias2
echo y | cmd execute myalias2

rm -rf $HOME/cmds
