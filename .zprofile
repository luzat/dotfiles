if [[ -o rcs ]]; then
    # Add node to path if not interactive (otherwise .zshrc will load nvm)
    (( $+functions[nvm] )) && [[ -o interactive ]] || [[ -s ~/.nvm/nvm.sh ]] && . ~/.nvm/nvm.sh
fi

