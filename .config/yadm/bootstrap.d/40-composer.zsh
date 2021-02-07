#!/usr/bin/env zsh

set -eu

target=~/.local/bin/composer

curl -fsLo "$target.tmp" https://getcomposer.org/composer-stable.phar
chmod +x "$target.tmp"
rm -f "$target"
mv "$target.tmp" "$target"

