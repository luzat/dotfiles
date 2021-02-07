#!/usr/bin/env zsh

set -eu

if { ! (( $+commands[chroma] )) || [[ -x ~/go/bin/chroma ]] } && (( $+commands[go] )); then
    go get -u github.com/alecthomas/chroma/cmd/chroma
fi

