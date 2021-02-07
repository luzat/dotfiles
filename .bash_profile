# Invoked for login shells

# Include generic environment
[[ -f ~/.config/shellenv ]] && source ~/.config/shellenv

# Include interactive setup in login shells
[[ -f ~/.bashrc ]] && source ~/.bashrc

