#!/bin/sh

set -eu

OPT_PATH="$HOME/.local/opt"

if [ -d ~/.yadm ]; then
    echo -n "Remove old ~/.yadm (y/n)? "
    read choice

    if [ "$choice" != "${choice#[Yy]}" ]; then
        rm -rf ~/.yadm 
    fi
fi

mkdir -p ~/.local/bin "$OPT_PATH"

PATH="$HOME/.local/bin:$PATH"

if [ -d "$OPT_PATH/yadm" ]; then
    git -C "$OPT_PATH/yadm" pull
else
    git clone https://github.com/TheLocehiliosan/yadm.git "$OPT_PATH/yadm"
fi

if [ -e ~/.local/bin/yadm ]; then
    rm ~/.local/bin/yadm
fi

ln -s ../opt/yadm/yadm ~/.local/bin/yadm                    

if yadm remote > /dev/null 2>&1; then
    yadm pull
else
    yadm clone --no-bootstrap https://github.com/luzat/dotfiles.git
    yadm remote set-url origin --push git@github.com:luzat/dotfiles.git
fi

echo -n "Decrypt files (y/n)? "
read choice

if [ "$choice" != "${choice#[Yy]}" ]; then
    yadm decrypt
fi

echo -n "Bootstrap (y/n)? "
read choice

if [ "$choice" != "${choice#[Yy]}" ]; then
    yadm bootstrap
fi

