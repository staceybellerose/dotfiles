#!/usr/bin/env bash
# shellcheck disable=SC1091

# load bash completions
[[ -r /usr/share/bash-completion/completions/git ]] && . /usr/share/bash-completion/completions/git
[[ -r /usr/share/bash-completion/completions/tar ]] && . /usr/share/bash-completion/completions/tar

# define aliases
alias vi="gvim"
alias stfu="amixer set Master mute"
alias unmute="amixer set Master unmute"
alias pumpitup="amixer set Master unmute; amixer set Master 100%"
alias trash="gio trash"
