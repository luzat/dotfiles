#!/usr/bin/env zsh

set -eu

target="$OPT_PATH/fzf"

fzf_install() {
    "$target/install" --xdg --key-bindings --completion --no-fish --no-update-rc
}

if [[ -d "$target" ]]; then
    git -C "$target" pull
    fzf_install
elif ! (( $+commands[fzf] )); then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$target"
    fzf_install
fi

