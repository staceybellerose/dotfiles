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
# Android Settings
##

adbd () {
	adb -s $(get_device) "$@"
}

function get_device() {
	local devices=$(adb devices | grep device$)
	if [ $(wc -l <<< "$devices") -eq 1 ]; then
		awk {'print $1'} <<< "$devices" 
	else
		IFS=$'\n' devices=($devices)
		unset IFS
		local device
		PS3="Select a device # "
		select device in "${devices[@]}"; do
			if [ -n "$device" ]; then
				awk {'print $1'} <<< "$device"
			fi
			break
		done
	fi
}

function logcat() {
	local device
	device=$(get_device)
	if [ -z "$1" ]
	then
		adb -s $device logcat | coloredlogcat.py
	else
			local filters=""
			for f in $@
			do
			export filters="$filters $f:*"
			done
			echo "filters $filters"
		adb -s $device logcat $filters *:S | coloredlogcat.py	
	 fi
}

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


##
# Load any platform-specific resources
##

arch=$(uname -s)
machinearch=$(uname -m)
[ -f $HOME/.bashd/extra_$arch.bashrc ] && . $HOME/.bashd/extra_$arch.bashrc
[ -f $HOME/.bashd/extra_${arch}_${machinearch}.bashrc ] && . $HOME/.bashd/extra_${arch}_${machinearch}.bashrc

