#!/usr/bin/env bash
# shellcheck disable=SC2181

# Use this script for any Ruby gem installations

source ./bin/utils.sh

gui="$1"
yes="$2"
debug="$3"

hasRuby () {
    (type -P ruby && type -P gem) &> /dev/null
    return $?
}

hasRubyGem () {
    hasRuby || return
    gem list | grep -q "$1" &> /dev/null
    return $?
}

installRubyGem () {
    hasRuby || return
    gem="$1"
    system="$2"
    if ! hasRubyGem "$gem"
    then
        if [[ $system -eq 1 ]]
        then
            gem install -q "$gem"
        else
            gem install -q --user-install "$gem"
        fi
        hasRubyGem "$gem"
        reportResult "$gem successfully installed" "$gem not installed"
    fi
}

installRubyGems () {
    hasRuby || return
    gems=$1
    system=$2
    if [[ $system -eq 1 ]]
    then
        g_bold "Installing Ruby system gems"
    else
        g_bold "Installing Ruby user gems"
    fi
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
        installRubyGem "$gem" "$system"
    done
}

declare -a system_gems=(
    "bundler"
)
declare -a user_gems=(
    "jekyll"
)

g_header "Ruby Gem Installer"
installRubyGems "${system_gems[@]}" 1
installRubyGems "${user_gems[@]}" 0
