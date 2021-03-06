#!/bin/sh

set -eu

zsh="$OPT_PATH/ohmyzsh"
zsh_plugins="$zsh/custom/plugins"

if [ -d "$zsh" ]; then
    git -C "$zsh" pull > /dev/null
else
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$zsh"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ -d "$zsh_plugins/$plugin" ]; then
        git -C "$zsh_plugins/$plugin" pull > /dev/null
    else
        git clone https://github.com/zsh-users/$plugin "$zsh_plugins/$plugin"
    fi
done

if [ -d "$zsh_plugins/fzf-tab" ]; then
    git -C "$zsh_plugins/fzf-tab" pull > /dev/null
else
    git clone https://github.com/Aloxaf/fzf-tab "$zsh_plugins/fzf-tab"
fi

