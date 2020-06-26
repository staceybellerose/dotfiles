#!/usr/bin/env bash

# load dircolors
[[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

# load bash completions for git
[[ -r /usr/share/bash-completion/completions/git ]] && . /usr/share/bash-completion/completions/git
