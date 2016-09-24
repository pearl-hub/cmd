#!/bin/bash

cmd help

export EDITOR="eval echo ls -l >"
cmd add myalias

cmd list

cmd print myalias

echo y | cmd execute myalias
