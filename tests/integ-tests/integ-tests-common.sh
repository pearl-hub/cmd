#!/bin/bash

cmd help

# Test user defined commands
export EDITOR="eval echo ls -l >"
cmd add myalias

cmd list
cmd print myalias
echo y | cmd execute myalias
# Alternative execution:
myalias

cmd remove myalias

# Test third-party commands
mkdir -p $HOME/cmds
echo "pwd" > $HOME/cmds/myalias2
chmod +x $HOME/cmds/myalias2
export CMD_PATH=$CMD_PATH:$HOME/cmds

cmd list
cmd print myalias2
echo y | cmd execute myalias2

rm -rf $HOME/cmds

pearl update test

pearl remove test
