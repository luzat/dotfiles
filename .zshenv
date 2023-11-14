# Path setup
typeset -Ux MANPATH manpath
typeset -Ux PATH path

# Shared environment for bash and zsh
[[ -f ~/.config/env ]] && source ~/.config/env

for f in ~/.config/env.d/*.{sh,zsh}(-.N); do
    . "$f"
done

# Remove missing paths
path=($^path(N-/))

# Back up path to restore it after /etc/profile overwrites it
[[ -o login ]] && path_backup=($path)

