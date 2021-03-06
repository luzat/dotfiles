#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if { ! (( $+commands[exa] )) || [[ -x ~/.cargo/bin/exa ]] } &&
    (( $+commands[cargo] ));
then
    cargo install exa 
fi

