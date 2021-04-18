#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if (( $+commands[pip] )); then
    pip install --user pipx
    pipx install pipenv || pipx upgrade pipenv
fi

target="$OPT_PATH/pyenv"

if [[ -d "$target" ]]; then
    git -C "$target" pull > /dev/null
else
    git clone https://github.com/pyenv/pyenv.git "$target"
fi

target="$OPT_PATH/pyenv/plugins/pyenv-virtualenv"

if [[ -d "$target" ]]; then
    git -C "$target" pull > /dev/null
else
    git clone https://github.com/pyenv/pyenv-virtualenv.git "$target"
fi

