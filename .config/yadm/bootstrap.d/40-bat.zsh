#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if { ! { (( $+commands[bat] )) || (( $+commands[batcat] )) } || [[ -x ~/.cargo/bin/bat ]] } &&
    (( $+commands[cargo] ));
then
    cargo install bat 
fi

