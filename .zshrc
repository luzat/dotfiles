# Set file mask
umask 022

# Use some XDG paths for zsh
ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"
ZSH_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
[[ -d "$ZSH_STATE_DIR" ]] || mkdir -p "$ZSH_STATE_DIR"

HISTFILE="$ZSH_STATE_DIR/history"

# Change directory for zcompdump files
# Partially taken from oh-my-zsh.sh to use the same file name
() {
    local short_host

    if [[ -z "$ZSH_COMPDUMP" ]]; then
        if [[ "$OSTYPE" = darwin* ]]; then
            short_host=$(scutil --get ComputerName 2>/dev/null) || short_host="${HOST/.*/}"
        else
            short_host="${HOST/.*/}"
        fi

        ZSH_COMPDUMP="${ZSH_CACHE_DIR:-$HOME}/.zcompdump-${short_host}-${ZSH_VERSION}"
    fi
}

# Oh My Zsh configuration
ZSH="{$XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh"
[[ -d "$ZSH" ]] || ZSH="$HOME/.local/opt/ohmyzsh"

# Give up
[[ -d "$ZSH" ]] || return

ZSH_THEME="${ZSH_THEME:-agnoster}"
DEFAULT_USER="${DEFAULT_USER:-tom}"
CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
VI_MODE_SET_CURSOR="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=1024
VIRTUAL_ENV_DISABLE_PROMPT=1

# Oh My Zsh plugins
plugins=(
    asdf
    colored-man-pages
    command-not-found
    composer
    dircycle
    direnv
    gh
    kubectl
    magic-enter
    npm
    pip
    pm2
    poetry
    rust
    symfony2
    vi-mode
)

for plugin in fzf-tab zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -d "$ZSH/custom/plugins/$plugin" ]] && plugins+="$plugin"
done

for cmd in adb ufw yarn zoxide; do
    (( $+commands[$cmd] )) && plugins+="$cmd"
done

(( $+commands[docker] )) && plugins+=("docker" "docker-compose")
(( $+commands[rg] )) && plugins+="ripgrep"
(( $+commands[systemctl] )) && plugins+="systemd"
(( $+commands[wp] )) && plugins+="wp-cli"

if (( $+commands[chroma] )); then
    ZSH_COLORIZE_TOOL="chroma"
    ZSH_COLORIZE_STYLE="monokai"
    plugins+="colorize"
elif (( $+commands[pygmentize] )); then
    ZSH_COLORIZE_STYLE="monokai"
    plugins+="colorize"
fi

# SSH agent
# Forward to Windows' SSH agent on WSL 2, see: https://github.com/rupor-github/wsl-ssh-agent
# TODO: Test 
if (( $+commands[socat] )) && [[ ! -v SSH_AUTH_SOCK && -x ~/.local/opt/wsl/npiperelay.exe ]]; then
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
    ss -a | grep -q "$SSH_AUTH_SOCK"
    if [[ $? -ne 0 ]]; then
        rm -f "$SSH_AUTH_SOCK"
        setsid -f socat "UNIX-LISTEN:$SSH_AUTH_SOCK,fork" EXEC:"$HOME/.local/opt/wsl/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork
    fi
fi

if [[ -z "$SSH_AUTH_SOCK" ]]; then
    plugins+=ssh-agent
    zstyle :omz:plugins:ssh-agent agent-forwarding yes
    zstyle :omz:plugins:ssh-agent lazy yes
fi

# directory colors (ls)
(( ! $+LS_COLORS && $+commands[dircolors] )) && [[ -f "$XDG_CONFIG_HOME/dircolors" ]] && eval "$(dircolors "$XDG_CONFIG_HOME/dircolors")"

# Magic enter
(( $+commands[eza] )) && MAGIC_ENTER_OTHER_COMMAND="eza -Bgl" || MAGIC_ENTER_OTHER_COMMAND="ls -l"

# asdf
# https://asdf-vm.com/
if [[ -d "$OPT_PATH/asdf" ]]; then
    export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdfrc"
    export ASDF_DIR="$OPT_PATH/asdf"
    export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
    export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
fi

# yadm
# https://yadm.io/
[[ -d "$OPT_PATH/yadm/completion/zsh" ]] && fpath+="$OPT_PATH/yadm/completion/zsh"

# less
if (( $+commands[less] && ! ${+LESSOPEN} )); then
    if (( $+commands[lesspipe.sh] )); then
        # https://github.com/wofr06/lesspipe
        export LESSOPEN="|${commands[lesspipe.sh]} %s"
    elif (( $+commands[lesspipe] )); then
        eval "$(lesspipe)"
    fi
fi

# GnuPG
if (( $+commands[gpgconf] )); then
    AGENT_SOCK="$(gpgconf --list-dirs | grep agent-socket | cut -d : -f 2)"

    if (( $+commands[gpg-agent] )) && [[ ! -S "$AGENT_SOCK" ]]; then
        gpg-agent --daemon --use-standard-socket &>/dev/null
    fi
fi

export GPG_TTY="$(tty)"

# Go
if (( $+commands[go] )); then
    path=("$(go env GOPATH)/bin" $path)
    plugins+="golang"
fi

# Ruby: rbenv
if [[ -d "$OPT_PATH/rbenv" ]]; then
    path=("$OPT_PATH/rbenv/bin" $path)
    eval "$(rbenv init - --no-rehash)"
fi
#
# Additional completions
# Using a custom directory, because $ZSH/completions is not gitignored
fpath+="$ZSH/custom/completions"

# Initialize Oh My Zsh
. "$ZSH/oh-my-zsh.sh"

# Autocomplete
(( $+commands[zoxide] )) && +autocomplete:recent-directories() {
    reply=( ${(f)"$( zoxide query --list $1 2> /dev/null )"} )
}

bindkey "${terminfo[kcuu1]}" up-line-or-history

# Python: pipenv, pyenv
_pipenv() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _PIPENV_COMPLETE=complete-zsh pipenv)
}
compdef _pipenv pipenv

if [[ -d "$OPT_PATH/pyenv" ]]; then
    export PYENV_ROOT="$OPT_PATH/pyenv"
    path=("$PYENV_ROOT/bin" $path)
    eval "$(pyenv init - --no-rehash)"

    if [[ -d "$OPT_PATH/pyenv/plugins/pyenv-virtualenv" ]]; then
        export PYENV_VIRTUALENV_DISABLE_PROMPT=1
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# Prompt setup: Patch agnoster prompt
prompt_status() {
    local symbols

    # Patched: Include history event number
    symbols+="%!"
    # Patched: include $RETVAL
    [[ $RETVAL -ne 0 ]] && symbols+=" %{%F{red}%}$RETVAL✘"
    # Patched: include job count and reverse order
    [[ -n "$jobstates" ]] && symbols+=" %{%F{cyan}%}%(1j.%j.)⚙"

    # Changed background color
    [[ -n "$symbols" ]] && prompt_segment '#232526' default "$symbols"
}

prompt_context() {
    if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        if [[ $UID -eq 0 ]]; then
            prompt_segment '#232526' default "%(!.%{%F{yellow}%}.)⚡%n@%m"
        else
            prompt_segment '#232526' default "%(!.%{%F{yellow}%}.)%n@%m"
        fi
    fi
}

prompt_virtualenv () {
    local virtualenv_path="$VIRTUAL_ENV"

    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
        prompt_segment magenta white $'\ue235'"`basename $virtualenv_path`"
    fi
}

# History
setopt histignorespace
HISTSIZE=50000
SAVEHIST=50000

# Vi mode
KEYTIMEOUT=1

# Open command line in editor; vv doesn't work because of low KEYTIMEOUT
bindkey -M vicmd '^v' edit-command-line

# Menu selection: hjkl
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Reverse completion: Shift-Tab
bindkey -M viins '^[[Z' reverse-menu-complete
bindkey -M vicmd '^[[Z' reverse-menu-complete

# Erasing characters
bindkey '^u' backward-kill-line
bindkey '^d' delete-char
bindkey '^k' vi-kill-eol

# Line editing
bindkey '^q' push-line-or-edit
bindkey '^[^M' self-insert-unmeta

# dircycle: Alt+Left/Right
bindkey "\e[3D" insert-cycledleft
bindkey "\e[1;3D" insert-cycledleft
bindkey "\e\e[D" insert-cycledleft
bindkey "\eO3D" insert-cycledleft
bindkey "\e[3C" insert-cycledright
bindkey "\e[1;3C" insert-cycledright
bindkey "\e\e[C" insert-cycledright
bindkey "\eO3C" insert-cycledright

# fancy-ctrl-z for vi-mode
_fancy-ctrl-z () {
    (( $#BUFFER > 0 )) && zle push-input -w
    BUFFER="fg"
    zle accept-line -w
}

zle -N _fancy-ctrl-z
bindkey '^Z' _fancy-ctrl-z
bindkey -M vicmd '^Z' _fancy-ctrl-z
bindkey -M viins '^Z' _fancy-ctrl-z

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+="_fancy-ctrl-z"

# Improve paste speed with zsh-syntax-highlighting.zsh
# https://github.com/zsh-users/zsh-autosuggestions/issues/351#issuecomment-483938570
_paste_init() {
    zle -A self-insert self-insert-before-paste
    zle -N self-insert url-quote-magic
}

_paste_finish() {
    zle -A self-insert-before-paste self-insert
}

zstyle :bracketed-paste-magic paste-init _paste_init
zstyle :bracketed-paste-magic paste-finish _paste_finish

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+="bracketed-paste"

# Anaconda
() {
    if [[ -d "$OPT_PATH/anaconda3" ]]; then
        local conda_path="$OPT_PATH/anaconda3"
    elif [[ -d ~/anaconda3 ]]; then
        local conda_path=~/anaconda3
    else
        return
    fi

    if [[ -v conda_path ]]; then
        local conda_setup="$("$conda_path/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"

        if [[ $? -eq 0 ]]; then
            eval "$conda_setup"
        else
            if [[ -f "$conda_path/etc/profile.d/conda.sh" ]]; then
                . "/$conda_path/etc/profile.d/conda.sh"
            else
                path=("$conda_path/bin" $path)
            fi
        fi
    fi
}

# ugrep
# https://github.com/Genivia/ugrep
() {
    if (( $+commands[ugrep] )); then
        local ugrep_flags='--exclude-dir={.bzr,CVS,.git,.hg,.svn,node_modules} --color=auto --sort -. -U -Y'

        alias grep="ugrep $ugrep_flags -G"
        alias egrep="ugrep $ugrep_flags -E"
        alias fgrep="ugrep $ugrep_flags -F"
        alias zgrep="ugrep $ugrep_flags -G -z"
        alias zegrep="ugrep $ugrep_flags -E -z"
        alias zfgrep="ugrep $ugrep_flags -F -z"
    fi
}

# fzf setup
# https://github.com/junegunn/fzf
# C-t: Select files/directories
# C-r: Select from history
# M-c: Switch directory
() {
    if (( $+commands[fzf] )); then
        [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && . /usr/share/doc/fzf/examples/key-bindings.zsh
        [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && . /usr/share/doc/fzf/examples/completion.zsh

        local fzf_cmd_files="find . '!' -name . -name '.*' -prune -o -type f -print | cut -d/ -f2-"
        local fzf_cmd_files_h="find . -type f | cut -d/ -f2-"
        local fzf_cmd_dirs="find . '!' -name . -name '.*' -prune -o -type d -print | cut -d/ -f2-"
        local fzf_cmd_dirs_h="find . -type d | cut -d/ -f2-"
        local fzf_cmd_fhere="printf %s *(N-^/P."$'\n'".)"
        local fzf_cmd_fhere_h="printf %s *(ND-^/P."$'\n'".)"
        local fzf_cmd_ahere="printf %s *(N^P."$'\n'".)"
        local fzf_cmd_ahere_h="printf %s *(ND^P."$'\n'".)"
        local fzf_cmd_bindings=(
            "ctrl-q:reload($fzf_cmd_dirs)"
            "ctrl-alt-q:reload($fzf_cmd_dirs_h)"
            "ctrl-t:reload($fzf_cmd_files)"
            "ctrl-alt-t:reload($fzf_cmd_files_h)"
            "ctrl-z:reload($fzf_cmd_ahere)"
            "ctrl-alt-z:reload($fzf_cmd_ahere_h)"
            "ctrl-f:reload($fzf_cmd_fhere)"
            "ctrl-alt-f:reload($fzf_cmd_fhere_h)"
        )

        export FZF_DEFAULT_COMMAND="$fzf_cmd_files"
        export FZF_DEFAULT_OPTS="--exact --cycle --height=60% --min-height=15"
        export FZF_CTRL_T_COMMAND="$fzf_cmd_files"
        export FZF_CTRL_T_OPTS="--bind \"${(j:,:)fzf_cmd_bindings}\" --preview 'fzf-preview.sh {}'"

        # fzf-tab
        # https://github.com/Aloxaf/fzf-tab
        zstyle ":completion:*:git-checkout:*" sort "false"
        zstyle ':completion:*:descriptions' format "[%d]"
        zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'fzf-preview.sh $realpath'

        enable-fzf-tab
    fi
}

# Hack: Set up X11 authorization on terminals missing $XAUTHORITY
[[ ! -v $XAUTHORITY && -f ~/.Xauthority ]] && export XAUTHORITY=~/.Xauthority

# Batcat setup
(( ! $+commands[bat] && $+commands[batcat] )) && alias bat="batcat"

# Open files in associated applications
if (( $+commands[xdg-open] )); then
    for ext in csv doc docx md ods odt pdf sql txt xls xlsx; do
        alias -s $ext="xdg-open"
    done
fi

# Additional aliases
alias ip='ip -c=auto'

# Export device IP as $LHOST
lhost() {
    ip -o -4 a s dev "${1:-tun0}" | awk '{split($4,ip,"/");print "export LHOST=" ip[1]}'
}

setlhost() {
    eval `lhost "${1:-tun0}"`
}

compdef '_arguments -s 1:interface:_net_interfaces' lhost setlhost

# Remove non-existing paths
path=($^path(N-/))

# Avoid exiting with error code
true

