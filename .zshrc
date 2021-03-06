# Oh My Zsh configration
ZSH="$OPT_PATH/ohmyzsh"
ZSH_THEME="agnoster"
DEFAULT_USER="tom"
CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_CORRECTION="true"
VI_MODE_SET_CURSOR="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=1024

# Oh My Zsh plugins
plugins=(
    colored-man-pages
    command-not-found
    composer
    dircycle
    direnv
    fasd # https://github.com/clvv/fasd
    fzf-tab
    magic-enter
    pip
    symfony2
    vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
)

for cmd in adb docker docker-compose flutter git rustup ufw; do
    (( $+commands[$cmd] )) && plugins+="$cmd"
done

(( $+commands[rg] )) && plugins+="ripgrep"
(( $+commands[rustc] )) && plugins+="rust"
(( $+commands[systemctl] )) && plugins+="systemd"

if (( $+commands[chroma] )); then
    ZSH_COLORIZE_TOOL="chroma"
    ZSH_COLORIZE_STYLE="monokai"
    plugins+="colorize"
elif (( $+commands[pygmentize] )); then
    ZSH_COLORIZE_STYLE="monokai"
    plugins+="colorize"
fi

# directory colors (ls)
(( ! ${+LS_COLORS} && $+commands[dircolors] )) && [[ -f "$XDG_CONFIG_HOME/dircolors" ]] && eval "$(dircolors "$XDG_CONFIG_HOME/dircolors")"

# Magic enter
if (( $+commands[exa] )); then
    MAGIC_ENTER_OTHER_COMMAND="exa -Bgl ."
else
    MAGIC_ENTER_OTHER_COMMAND="ls -l ."
fi

# yadm
# https://yadm.io/
[[ -d "$OPT_PATH/yadm/completion/zsh" ]] && fpath=("$OPT_PATH/yadm/completion/zsh" $fpath)

# less
if (( ! ${+LESSOPEN} )); then
    if (( $+commands[lesspipe] )); then
        eval "$(lesspipe)"
    elif (( $+commands[lesspipe.sh] )); then
        # https://github.com/wofr06/lesspipe
        export LESSOPEN="|${commands[lesspipe.sh]} %s"
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

# Android SDK
# https://developer.android.com/studio#downloads
if (( ! ${+ANDROID_HOME} )) && [[ -d "$OPT_PATH/android-sdk" ]]; then
    export ANDROID_HOME="$OPT_PATH/android-sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    path=("$ANDROID_HOME/tools/bin" "$ANDROID_HOME/platform-tools" $path)
fi

# ESP-IDF
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/#installation-step-by-step
if (( ! ${+IDF_PATH} )) && [[ -d "$OPT_PATH/esp-idf" ]]; then
    export IDF_PATH="$OPT_PATH/esp-idf"
    source "$IDF_PATH/export.sh" > /dev/null 2>&1
fi

# Go
if (( $+commands[go] )); then
    path=("$(go env GOPATH)/bin" $path)
    plugins+="golang"
fi

# NodeJS: fnm
if (( $+commands[fnm] )); then
    # Remove old path first for nested shells
    (( ${+FNM_MULTISHELL_PATH} )) && path[$path[(i)$FNM_MULTISHELL_PATH]]=()

    eval "$(fnm env)"
    fpath=("$ZSH/custom/plugins/fnm" $fpath)

    (( ${+FNM_PREVIOUS_ERROR} )) || export FNM_PREVIOUS_ERROR=""

    _fnm_autoload_hook () {
        local current="$(fnm current)"
        local dir="$PWD"

        while [[ "$dir" != "" && ! -e "$dir/.node-version" && ! -e "$dir/.nvmrc" ]]; do
            dir="${dir%/*}"
        done

        if [[ -e "$dir/.node-version" ]]; then
            version="$(<"$dir/.node-version")"
        elif [[ -e "$dir/.nvmrc" ]]; then
            version="$(<"$dir/.nvmrc")"
        else
            version="default"
        fi

        local fnm_error="$(fnm use "$version" 2>&1 > /dev/null)"

        if (( ${#fnm_error} )) && [[ "$fnm_error" != "$FNM_PREVIOUS_ERROR" && "$version" != "default" ]]; then
            echo "fnm/node: $fnm_error" 1>&2 
        fi

        FNM_PREVIOUS_ERROR="$fnm_error"

        local new="$(fnm current)"

        if [[ "$new" != "$current" ]]; then
            echo "fnm/node: Switched to node $new" 
        fi
    }

    autoload -U add-zsh-hook
    add-zsh-hook chpwd _fnm_autoload_hook
    _fnm_autoload_hook > /dev/null
fi

(( $+commands[npm] )) && plugins+=(npm yarn)

# Python: pyenv
if [[ -d "$OPT_PATH/pyenv" ]]; then
    export PYENV_ROOT="$OPT_PATH/pyenv"
    path=("$PYENV_ROOT/bin" $path)
    eval "$(pyenv init - --no-rehash)"
fi

# Ruby: rbenv
if [[ -d "$OPT_PATH/rbenv" ]]; then
    path=("$OPT_PATH/rbenv/bin" $path)
    eval "$(rbenv init - --no-rehash)"
fi

# Initialize Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Prompt setup: Patch agnoster prompt
prompt_status() {
  local symbols

  # Patched: Include history event number
  symbols+="%!"
  # Patched: include $RETVAL
  [[ $RETVAL -ne 0 ]] && symbols+=" %{%F{red}%}$RETVAL✘"
  # Patched: include job count and reverse order
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+=" %{%F{cyan}%}%(1j.%j.)⚙"

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

# History
setopt histignorespace
export HISTSIZE=50000
export SAVEHIST=50000

# Vi mode
export KEYTIMEOUT=1

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
fancy-ctrl-z () {
   (( $#BUFFER > 0 )) && zle push-input -w
   BUFFER="fg"
   zle accept-line -w
}

zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
bindkey -M vicmd '^Z' fancy-ctrl-z
bindkey -M viins '^Z' fancy-ctrl-z

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+="fancy-ctrl-z"

# Improve paste speed with zsh-syntax-highlighting.zsh
# https://github.com/zsh-users/zsh-autosuggestions/issues/351#issuecomment-483938570
paste_init() {
  zle -A self-insert self-insert-before-paste
  zle -N self-insert url-quote-magic
}

paste_finish() {
  zle -A self-insert-before-paste self-insert
}

zstyle :bracketed-paste-magic paste-init paste_init
zstyle :bracketed-paste-magic paste-finish paste_finish

ZSH_AUTOSUGGEST_CLEAR_WIDGETS+="bracketed-paste"

# ugrep
# https://github.com/Genivia/ugrep
setup_ugrep() {
    if (( $+commands[ugrep] )); then
        local ugrep_flags='--exclude-dir={.bzr,CVS,.git,.hg,.svn,node_modules} --color=auto --sort -. -U -Y'

        alias grep="ugrep $ugrep_flags -G"
        alias egrep="ugrep $ugrep_flags -E"
        alias fgrep="ugrep $ugrep_flags -F"
        alias zgrep="ugrep $ugrep_flags -G -z"
        alias zegrep="ugrep $ugrep_flags -E -z"
        alias zfgrep="ugrep $ugrep_flags -F -z"
    fi

    unfunction setup_ugrep
}

setup_ugrep

# fzf setup
# https://github.com/junegunn/fzf
# C-t: Select files/directories
# C-r: Select from history
# M-c: Switch directory
setup_fzf() {
    if [[ -f "$XDG_CONFIG_HOME/fzf/fzf.zsh" ]]; then
        source "$XDG_CONFIG_HOME/fzf/fzf.zsh"
    elif [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        # Debian package
        source /usr/share/doc/fzf/examples/key-bindings.zsh
        
        # Missing for older versions
        [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    fi

    if (( $+commands[fzf] )); then
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

    unfunction setup_fzf
}

setup_fzf

# Offload applications to NVIDIA graphics
# https://download.nvidia.com/XFree86/Linux-x86_64/460.56/README/primerenderoffload.html
# https://wiki.debian.org/NVIDIA%20Optimus#Using_NVIDIA_PRIME_Render_Offload
nvoff() {
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia "$@"
}

# Hack: Set up X11 authorization on terminals missing $XAUTHORITY
(( ! ${+XAUTHORITY} )) && [[ -f ~/.Xauthority ]] && export XAUTHORITY=~/.Xauthority

# Batcat setup
(( ! $+commands[bat] )) && (( $+commands[batcat] )) && alias bat="batcat"

# Open files in associated applications
if (( $+commands[xdg-open] )); then
    for ext in csv doc docx md ods odt sql txt xls xlsx; do
        alias -s $ext="xdg-open"
    done
fi 

# Remove non-existing paths
path=($^path(N-/))

# Avoid exiting with error code
true

