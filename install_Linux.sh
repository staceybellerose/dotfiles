#!/usr/bin/env bash
# shellcheck disable=SC1091

# Use this script for any Linux-based specific installations

source ./bin/utils.sh

packages="$1"
fonts="$2"
config="$3"
# shellcheck disable=SC2034
xcode="$4"
gui="$5"
yes="$6"

if [[ $gui -eq 0 ]]
then
    CPOPT=-av
else
    CPOPT=-a
fi

installFonts () {
    g_bold "Installing Fonts"
    mkdir -p "${HOME}/.fonts"
    for dir in fonts/*
    do
        if [ -d "$dir" ]
        then
            fontname=$(basename "$dir")
            if [ -d "${HOME}/.fonts/${fontname}" ]
            then
                g_arrow "${fontname} is already installed"
            else
                cp $CPOPT "$dir" "${HOME}/.fonts" && g_success "Installed font: ${fontname}" || g_error "Unable to install font: ${fontname}"
            fi
        fi
    done
    fc-cache
}

installConfig () {
    g_bold "Installing Configuration Files"
    mkdir -p "${HOME}/.config"
    cp $CPOPT config/* "${HOME}/.config" && g_success "Installed config files" || g_error "Unable to install config files"
    mkdir -p "${HOME}/.local"
    cp $CPOPT local/* "${HOME}/.local" && g_success "Installed share files" || g_error "Unable to install share files"
    # fix the absolute path in qt5ct.conf
    sed -i -- "s:color_scheme_path=.*:color_scheme_path=${HOME}/.config/qt5ct/colors/one dark.conf:g" "${HOME}/.config/qt5ct/qt5ct.conf" && g_success "Updated QT5 config file" || g_error "Unable to update QT5 config file"
}

isDebianDerivative () {
    which dpkg &> /dev/null
    return $?
}

hasDebianPackage () {
    dpkg -s "$1" &> /dev/null
    return $?
}

installDebianPackage () {
    isDebianDerivative || return
    if hasDebianPackage "$1"
    then
        g_arrow "$1 is already installed"
    else
        g_info "Installing package $1"
        sudo apt-get install "$1"
        hasDebianPackage "$1" && e_success "$1 successfully installed" || e_error "$1 not installed"
    fi
}

installDebianPackages () {
    isDebianDerivative || return
    g_bold "Installing Debian Packages"
    declare -a pkgs=(
        "arc-theme"
        "tango-icon-theme"
        "font-manager"
        "ruby"
        "rake"
        "rails"
        "scite"
        "ttf-xfree86-nonfree"
        "zenity"
    )
    toInstall=()
    for pkg in "${pkgs[@]}"
    do
        if hasDebianPackage "$pkg"
        then
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
        installDebianPackage "$pkg"
    done
}

isRedHatDerivative () {
    which rpm &> /dev/null
    return $?
}

installRedHatPackages () {
    isRedHatDerivative || return
    g_bold "Installing Red Hat Packages"
    ## TODO add packages here as needed
}

g_header "Linux Installer"

if [[ $config -eq 1 ]]
then
    installConfig
fi
if [[ $fonts -eq 1 ]]
then
    installFonts
fi
if [[ $packages -eq 1 ]]
then
    isDebianDerivative && installDebianPackages
    isRedHatDerivative && installRedHatPackages
fi
