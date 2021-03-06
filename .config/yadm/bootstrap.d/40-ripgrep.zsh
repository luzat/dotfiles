#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if { ! (( $+commands[rg] )) || [[ -x ~/.cargo/bin/rg ]] } && (( $+commands[cargo] )); then
    cargo install ripgrep
fi

