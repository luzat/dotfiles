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

yadm_class="$(yadm config local.class)"
hostname="$(hostname)"

if [ -z "$(yadm config local.class)" ]; then
    if [ "golemxiv" = "$hostname" ] || [ "wopr" = "$hostname" ]; then
        yadm_class="workstation"
    else
        echo "Workstation: EverythingInstall everything"
        echo "Client:      No development tools, less packages"
        echo "Minimal:     Minimal working setup"
        echo -n "Machine class workstation (w), client (c) or minimal (m)?"
        read choice

        if [ "$choice" != "${choice#[Ww]}" ]; then
            yadm_class="workstation"
        elif [ "$choice" != "${choice#[Cc]}" ]; then
            yadm_class="client"
        else
            yadm_class="minimal"
        fi
    fi

    yadm config local.class "$yadm_class"
fi

yadm alt

if [ "workstation" = "$yadm_class" ]; then
    echo -n "Decrypt files (y/n)? "
    read choice

    if [ "$choice" != "${choice#[Yy]}" ]; then
        yadm decrypt
    fi
fi

echo -n "Bootstrap (y/n)? "
read choice

if [ "$choice" != "${choice#[Yy]}" ]; then
    yadm bootstrap
fi

