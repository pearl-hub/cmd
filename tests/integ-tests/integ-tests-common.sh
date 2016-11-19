#!/bin/bash

pearl install test

cmd help

export EDITOR="eval echo ls -l >"
cmd add myalias

cmd list

cmd print myalias

echo y | cmd execute myalias

pearl update test

pearl remove test
