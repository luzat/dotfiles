#!/usr/bin/env zsh

set -eu

if [[ "$YADM_CLASS" != "workstation" ]]; then
    exit 0
fi

if { ! (( $+commands[fnm] )) || [[ -x ~/.cargo/bin/fnm ]] } && (( $+commands[cargo] ));
then
    cargo install fnm
    fnm=~/.cargo/bin/fnm
else
    fnm=fnm
fi

mkdir -p "$OPT_PATH/ohmyzsh/custom/plugins/fnm"
"$fnm" completions --shell zsh > "$OPT_PATH/ohmyzsh/custom/plugins/fnm/_fnm"

