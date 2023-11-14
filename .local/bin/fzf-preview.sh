#!/usr/bin/env zsh

argument="$1"

if ! [[ -a "$argument" ]]; then
    echo "$argument does not exist"
fi

if [[ -d "$argument" ]]; then
    if (( $+commands[eza] )); then
        eza -l --color=always "$argument"
    else
        ls -l "$argument"
    fi
elif [[ -b "$argument" ]] || [[ -c "$argument" ]] || [[ -h "$argument" ]] || [[ -p "$argument" ]] || [[ -S "$argument" ]]; then
    if (( $+commands[eza] )); then                                                                                                                                                                          
        eza -l -d --color=always "$argument"                                                                                                                                                             
    else
        ls -l -d "$argument"
    fi
elif [[ -f "$argument" ]]; then
    format="none"

    case "${argument:l}" in
        .htaccess|.*ignore|*.c|*.cpp|*.cs|*.csv|*.cxx|*.h|*.hpp|*.hxx|*.ini|*.js|*.jsx|*.log|*.md|*.mjs|*.php|*.py|*.sh|*.txt|*.ts|*.tsx|*.xml|*.yaml|*.yml|*.zsh)
            format="text"
            ;;
        *.gif|*.jpg|*.jpeg|*.png|*.svg|*.webp)
            format="image"
            ;;
        *)
            ;;
    esac

    mime=$(file -b --mime-type "$argument")

    case "$mime" in
        text/*)
            format="text"
            ;;
        image/*)
            format="image"
            ;;
    esac

    case "$format" in
        text)
            if command -v batcat > /dev/null; then
                batcat --style=numbers --color=always --line-range :500 "$argument"
            elif command -v bat > /dev/null; then
                bat --style=numbers --color=always --line-range :500 "$argument"
            elif command -v cless > /dev/null; then
                head -n 500 "$argument" | cless
            elif command -v less > /dev/null; then
                head -n 500 "$argument" | less
            else
                head -n 25 "$argument"
            fi
            ;;
        *)
            if command -v eza > /dev/null; then
                eza -l -d --color=always "$argument"
            else
                ls -l -d "$argument"
            fi

            echo
            file -b "$argument"

            case "$mime" in
                audio/*|image/*|video/*)
                    if command -v mediainfo > /dev/null; then
                        echo
                        mediainfo "$argument"
                    fi
                    ;;      
                esac
            ;;
    esac
fi

