#!/usr/bin/env zsh

set -eu

target="$OPT_PATH/pyenv"

if [[ -d "$target" ]]; then
    git -C "$target" pull
else
    git clone https://github.com/pyenv/pyenv.git "$target"
fi

