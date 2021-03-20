#!/bin/sh

set -eu

if command -v apt-get > /dev/null; then
    packages=""

    if [ "workstation" = "$YADM_CLASS" ] || [ "client" = "$YADM_CLASS" ]; then
        packages="fzf git htop mc neovim tmux zsh"
    fi

    if [ "workstation" = "$YADM_CLASS" ]; then
        packages="$packages bat cargo chroma command-not-found direnv exa fasd mediainfo opensc-pkcs11 plocate ranger ripgrep scdaemon ugrep"
    fi

    if [ -z "$packages" ]; then
        exit 0
    fi

    if [ "$(id -u)" -eq 0 ]; then
        echo "apt-get: Packages: $packages"
        echo -n "apt-get: Install (y/n)? "
        install_cmd="apt-get -y install"
    elif command -v sudo > /dev/null; then
        echo "apt-get: Candidates: $packages"
        echo -n "apt-get: Install packages using sudo (y/n)? "
        install_cmd="sudo apt-get -y install"
    else
        exit 0
    fi

    read choice

    if [ "$choice" != "${choice#[Yy]}" ]; then
        for package in $packages; do
            dpkg -s "$package" > /dev/null 2>&1 || $install_cmd "$package" || true
        done
    else
        echo
        echo "apt-get: Skipping installation."
    fi
fi

