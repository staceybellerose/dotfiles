#!/usr/bin/env bash

# Use this script for any Python3 package installations

source ./bin/utils.sh

gui="$1"
yes="$2"
debug="$3"

(( installed=0 ))

declare -a pkgs=(
    "adafruit-board-toolkit"
    "beautifulsoup4"
    "lxml"
    "requests"
)
declare -a root_pkgs=(
    "archey4"
    "mu-editor"
    "youtube-dl"
)

hasPython3 () {
    (type -P python3 && type -P pip3) &> /dev/null
    return $?
}

hasPythonPackage () {
    hasPython3 || return
    python3 -m pip list | grep "$1" &> /dev/null
    return $?
}

installPythonPackage () {
    hasPython3 || return
    if ! hasPythonPackage "$1"
    then
        python3 -m pip install -q "$1"
        hasPythonPackage "$1"
        (( installed++ ))
        reportResult "$1 successfully installed" "$1 not installed"
    fi
}

installRootPythonPackage () {
    hasPython3 || return
    if ! hasRootPythonPackage "$1"
    then
        sudo python3 -m pip install -q "$1"
        hasrootPythonPackage "$1"
        (( installed++ ))
        reportResult "$1 successfully installed" "$1 not installed"
    fi
}

displayInstallStats () {
    if ((installed > 0)); then
        g_success "$installed packages installed"
    else
        g_info "No packages to install"
    fi
}

promptToInstall () {
    pkg="$1"
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
    [[ $install = "y" ]]
    return $?
}

installPythonPackages () {
    hasPython3 || return
    g_bold "Installing Python packages"
    toInstall=()
    for pkg in "${pkgs[@]}"
    do
        if promptToInstall "$pkg"
        then
            toInstall+=( "$pkg" )
        fi
    done
    for pkg in "${toInstall[@]}"
    do
        installPythonPackage "$pkg"
    done
    displayInstallStats
}

installRootPythonPackages () {
    hasPython3 || return
    g_bold "Installing Root Python packages"
    toInstallRoot=()
    for pkg in "${root_pkgs[@]}"
    do
        if promptToInstall "$pkg"
        then
            toInstallRoot+=( "$pkg" )
        fi
    done
    for pkg in "${toInstallRoot[@]}"
    do
        installRootPythonPackage "$pkg"
    done
    displayInstallStats
}

g_header "Python Package Installer"
installPythonPackages
installRootPythonPackages
