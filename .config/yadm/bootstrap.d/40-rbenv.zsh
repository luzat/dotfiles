#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

target="$OPT_PATH/rbenv"

if [[ -d "$target" ]]; then
    git -C "$target" pull > /dev/null
else
    git clone https://github.com/rbenv/rbenv.git "$target"
fi

