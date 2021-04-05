#!/usr/bin/env zsh

set -eu

target="$OPT_PATH/fzf"

fzf_install() {
    "$target/install" --xdg --key-bindings --completion --no-fish --no-update-rc
}

if [[ -d "$target" ]]; then
    git -C "$target" pull > /dev/null
    fzf_install
elif ! (( $+commands[fzf] )) || [[ "$(command fzf --version)" =~ "^0.1" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$target"
    fzf_install
fi

