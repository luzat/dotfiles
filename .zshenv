# Path setup
typeset -U manpath
typeset -U path

# Shared environment for bash and zsh
source ~/.config/shellenv

# Remove missing paths
path=($^path(N-/))

