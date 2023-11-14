# Minimal interactive setup

# Set file mask
umask 022

# Update $LINES and $COLUMNS on resize
shopt -s checkwinsize

# Configure a simple colorful prompt
PS1='\[\033[01;34m\]\!\[\033[00m\]$(RETURN=$?; [ $RETURN -ne 0 ] && echo -ne ",\[\033[01;31m\]$RETURN\[\033[00m\]")$(JOBS=\j; [ $JOBS -ne 0 ] && echo -ne ",\[\033[01;32m\]$JOBS\[\033[00m\]"):\[\033[01;31m\]\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '

# If this is an xterm, set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*|cygwin)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033]0;${WINDOW}: ${USER}@${HOSTNAME}: ${PWD}\007"'
	;;
    *)
        ;;
esac

# Enable completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
fi

# Aliases
alias ..='cd ..'

