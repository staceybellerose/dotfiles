#!/usr/bin/env bash

##
# Mac-specific Paths
##

# use GNU programs instead of pre-installed Apple versions
PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
PATH="$(brew --prefix)/opt/gnu-getopt/libexec/gnubin:$PATH"
export PATH
