# Invoked for login shells

# Shared environment for bash and zsh
[[ -f ~/.config/env ]] && . ~/.config/env

shopt -u | grep -q nullglob && ngchanged=true && shopt -s nullglob

for f in ~/.config/env.d/*.{sh,bash}; do
    . "$f"
done

[ $ngchanged ] && shopt -u nullglob; unset ngchanged

# Load ~/.profile
[[ -f ~/.profile ]] && . ~/.profile

# Include interactive setup in login shells
[[ -f ~/.bashrc ]] && . ~/.bashrc

