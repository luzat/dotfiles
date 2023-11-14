# dotfiles

These dotfiles are managed with [yadm](https://yadm.io/). They are mostly focused on a Debian or Kali environment with
tmux, vim and zsh. Additional bootstrapping is done separately with Ansible.

## Installation

Installation should be idempotent.

```shell
sh -c "`curl -fsSL https://github.com/luzat/dotfiles/raw/main/.config/yadm/install.sh`"
```

