#!/bin/bash

##
# Mac-specific Settings
##

# colored terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Use MacVim as editor
alias vi="mvim"
alias finder="open ."

# taken from http://brettterpstra.com/2013/02/09/quick-tip-jumping-to-the-finder-location-in-terminal/
cdf() {
	target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
	if [ "$target" != "" ]; then
		cd "$target"; pwd
	else
		echo 'No Finder window found' >&2
	fi
}

alias f='open -a Finder ./'
