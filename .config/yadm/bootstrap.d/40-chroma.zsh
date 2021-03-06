#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if { ! (( $+commands[chroma] )) || [[ -x ~/go/bin/chroma ]] } &&
    (( $+commands[go] ));
then
    go get -u github.com/alecthomas/chroma/cmd/chroma
fi

