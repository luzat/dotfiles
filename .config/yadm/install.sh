#!/bin/sh

set -eu

OPT_PATH="$HOME/.local/opt"
PATH="$HOME/.local/bin:$PATH"

mkdir -p "$OPT_PATH" ~/.local/bin

if [ -d "$OPT_PATH/yadm" ]; then
    git -C "$OPT_PATH/yadm" pull
else
    git clone https://github.com/TheLocehiliosan/yadm.git "$OPT_PATH/yadm"
fi

if [ ! -e ~/.local/bin/yadm ]; then
    ln -s ../opt/yadm/yadm ~/.local/bin/yadm
fi

if [ -f ~/.config/yadm/bootstrap ]; then
    yadm pull
else
    yadm clone --no-bootstrap https://github.com/luzat/dotfiles.git
    yadm remote set-url origin --push git@github.com:luzat/dotfiles.git
fi

yadm alt
yadm bootstrap

