#!/usr/bin/env zsh

set -eu

if { ! (( $+commands[rg] )) || [[ -x ~/.cargo/bin/rg ]] } && (( $+commands[cargo] )); then
    cargo install ripgrep
fi

