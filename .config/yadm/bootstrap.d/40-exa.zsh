#!/usr/bin/env zsh

set -eu

if { ! (( $+commands[exa] )) || [[ -x ~/.cargo/bin/exa ]] } && (( $+commands[cargo] )); then
    cargo install exa 
fi

