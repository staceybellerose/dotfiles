#!/usr/bin/env bash

# Use this script for any Ruby gem installations

source ./bin/utils.sh

gui="$1"
yes="$2"
debug="$3"

(( installed=0 ))

declare -a gems=(
    "bundler"
    "jekyll"
)

hasRuby () {
    (type -P ruby && type -P gem) &> /dev/null
    return $?
}

hasRubyGem () {
    hasRuby || return
    gem list | grep "$1" &> /dev/null
    return $?
}

installRubyGem () {
    hasRuby || return
    if ! hasRubyGem "$1"
    then
        gem install -q "$1"
        hasRubyGem "$1"
        (( installed++ ))
        reportResult "$1 successfully installed" "$1 not installed"
    fi
}

installRubyGems () {
    hasRuby || return
    g_bold "Installing Ruby gems"
    toInstall=()
    for gem in "${gems[@]}"
    do
        if hasRubyGem "$gem"
        then
            [[ $debug -eq 1 ]] && g_success "$gem is already installed"
            install=n
        elif [[ $yes -eq 1 ]]
        then
            install=y
        else
            if [[ $gui -eq 0 ]]
            then
                read -rp "Do you want to install ${C_FORE_BLUE}$gem${C_RESET}? [y/${C_BOLD}n${C_RESET}]: " install
            else
                zenity --question --text="Do you want to install ${gem}?" \
                    --window-icon=./installer.svg --width=300 --height=100 && install=y
            fi
        fi
        if [[ $install == "y" ]]
        then
            toInstall+=( "$gem" )
        fi
    done
    for gem in "${toInstall[@]}"
    do
        installRubyGem "$gem"
    done
    if ((installed > 0)); then
        g_success "$installed gems installed"
    else
        g_info "No gems to install"
    fi
}

g_header "Ruby Gem Installer"
installRubyGems
