#!/usr/bin/env zsh

set -eu

target=~/.local/bin/fasd

if ! (( $+commands[fasd] )) || [[ -x "$target" ]]; then
    curl -fLo "$target.tmp" https://raw.githubusercontent.com/clvv/fasd/master/fasd
    chmod +x "$target.tmp"
    rm -f "$target"
    mv "$target.tmp" "$target"
fi

