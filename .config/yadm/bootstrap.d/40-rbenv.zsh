#!/usr/bin/env zsh

set -eu

target="$OPT_PATH/rbenv"

if [[ -d "$target" ]]; then
    git -C "$target" pull
else
    git clone https://github.com/rbenv/rbenv.git "$target"
fi

