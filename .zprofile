# Merge previous path with path after /etc/profile
if [[ -v path_backup ]]; then
    path=($path_backup $path)
    unset path_backup
fi

# Load ~/.profile
[[ -f ~/.profile ]] && emulate sh -c '. ~/.profile'

