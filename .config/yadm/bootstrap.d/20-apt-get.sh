#!/bin/sh

set -eu

if command -v apt-get > /dev/null; then
    packages="bat cargo chroma command-not-found direnv exa fasd fzf git htop mc mediainfo neovim plocate ranger ripgrep tmux ugrep zsh"

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
        $install_cmd $packages
    else
        echo
        echo "apt-get: Skipping installation."
    fi
fi

