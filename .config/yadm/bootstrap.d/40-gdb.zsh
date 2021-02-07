#!/usr/bin/env zsh

set -eu

target="$OPT_PATH/pwndbg"

if [[ -d "$target" ]]; then
    git -C "$target" pull
else
    git clone https://github.com/pwndbg/pwndbg.git "$target"
fi

if read -q "choice?pwndbg: Run setup.sh (y/n)? "; then
    echo
    "$OPT_PATH/pwndbg/setup.sh"
else
    echo
    echo "pwndbg: Skipping setup."
fi

target="$OPT_PATH/splitmind"

if [[ -d "$target" ]]; then
    git -C "$target" pull
else
    git clone https://github.com/jerdna-regeiz/splitmind.git "$target"
fi
