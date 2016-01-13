#!/bin/bash

##
# Set up environment variables
##

export PATH=${PATH}:${HOME}/bin
export LESS=-N
export EDITOR=vi

alias ll="ls -Flha"
alias dir="ls -Flha"
alias ls="ls -Fa"

##
# Colored Prompt Settings
##

# define colors
C_DEFAULT="\[\e[m\]"
C_WHITE="\[\e[1m\]"
C_BLACK="\[\e[30m\]"
C_RED="\[\e[31m\]"
C_GREEN="\[\e[32m\]"
C_YELLOW="\[\e[33m\]"
C_BLUE="\[\e[34m\]"
C_PURPLE="\[\e[35m\]"
C_CYAN="\[\e[36m\]"
C_LIGHTGRAY="\[\e[37m\]"
C_DARKGRAY="\[\e[1;30m\]"
C_LIGHTRED="\[\e[1;31m\]"
C_LIGHTGREEN="\[\e[1;32m\]"
C_LIGHTYELLOW="\[\e[1;33m\]"
C_LIGHTBLUE="\[\e[1;34m\]"
C_LIGHTPURPLE="\[\e[1;35m\]"
C_LIGHTCYAN="\[\e[1;36m\]"
C_BG_BLACK="\[\e[40m\]"
C_BG_RED="\[\e[41m\]"
C_BG_GREEN="\[\e[42m\]"
C_BG_YELLOW="\[\e[43m\]"
C_BG_BLUE="\[\e[44m\]"
C_BG_PURPLE="\[\e[45m\]"
C_BG_CYAN="\[\e[46m\]"
C_BG_LIGHTGRAY="\[\e[47m\]"

function prompt_command {
	local XTERM_TITLE="\e]2;\u@\H:\w\a"
 
	local BGJOBS_COLOR="$C_DARKGRAY"
	local BGJOBS=""
	if [ "$(jobs | head -c1)" ]; then BGJOBS=" $BGJOBS_COLOR(bg:\j)"; fi
 
	local DOLLAR_COLOR="$C_GREEN"
	if [[ ${EUID} == 0 ]] ; then DOLLAR_COLOR="$C_RED"; fi
	local DOLLAR="$DOLLAR_COLOR\\\$"
 
	local USER_COLOR="$C_GREEN"
	if [[ ${EUID} == 0 ]]; then USER_COLOR="$C_BG_RED$C_BLACK"; fi
 
	PS1="$XTERM_TITLE$USER_COLOR\u$C_GREEN@\H:\[\e[m\] $C_CYAN\w$C_DEFAULT\n\
$DOLLAR$BGJOBS \[\e[m\]"
}
export PROMPT_COMMAND=prompt_command

# taken from http://www.cyberciti.biz/faq/linux-unix-colored-man-pages-with-less-command/
man() {
	env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}

##
# clean up whiteboard photos (requires ImageMagick)
# taken from https://gist.github.com/lelandbatey/8677901
##
whiteboard () {
	convert "$1" -morphology Convolve DoG:15,100,0 -negate -normalize -blur 0x1 -channel RBG -level 60%,91%,0.1 "$2"
}

##
# Load any platform-specific resources
##

arch=$(uname -s)
machinearch=$(uname -m)
[ -f $HOME/.bashd/extra_$arch.bashrc ] && . $HOME/.bashd/extra_$arch.bashrc
[ -f $HOME/.bashd/extra_${arch}_${machinearch}.bashrc ] && . $HOME/.bashd/extra_${arch}_${machinearch}.bashrc

