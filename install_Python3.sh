#!/usr/bin/env bash

# Use this script for any Linux-based specific installations

source ./bin/utils.sh

gui="$1"
yes="$2"
debug="$3"

hasPython3 () {
    (type -P python3 && type -P pip3) &> /dev/null
    return $?
}

hasPythonPackage () {
    hasPython3 || return
    pip3 list | grep -q "$1" &> /dev/null
    return $?
}

installPythonPackage () {
    hasPython3 || return
    if ! hasPythonPackage "$1"
    then
        pip3 install -q "$1"
        hasPythonPackage "$1"
        reportResult "$1 successfully installed" "$1 not installed"
    fi
}

installPythonPackages () {
    hasPython3 || return
    g_bold "Installing Python packages"
    declare -a pkgs=(
        "archey4"
        "adafruit-board-toolkit"
        "mu-editor"
    )
    toInstall=()
    for pkg in "${pkgs[@]}"
    do
        if hasPythonPackage "$pkg"
        then
            [[ $debug -eq 1 ]] && g_success "$pkg is already installed"
            install=n
        elif [[ $yes -eq 1 ]]
        then
            install=y
        else
            if [[ $gui -eq 0 ]]
            then
                read -rp "Do you want to install ${C_FORE_BLUE}$pkg${C_RESET}? [y/${C_BOLD}n${C_RESET}]: " install
            else
                zenity --question --text="Do you want to install ${pkg}?" \
                    --window-icon=./installer.svg --width=300 --height=100 && install=y
            fi
        fi
        if [[ $install == "y" ]]
        then
            toInstall+=( "$pkg" )
        fi
    done
    for pkg in "${toInstall[@]}"
    do
        installPythonPackage "$pkg"
    done
}

g_header "Python Package Installer"
installPythonPackages
