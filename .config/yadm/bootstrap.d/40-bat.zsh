#!/usr/bin/env zsh

set -eu

if { ! { (( $+commands[bat] )) || (( $+commands[batcat] )) } || [[ -x ~/.cargo/bin/bat ]] } && (( $+commands[cargo] )); then
    cargo install bat 
fi

