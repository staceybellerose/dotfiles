#!/usr/bin/env bash
# shellcheck disable=SC1091

source ./bin/utils.sh

packages="$1"
fonts="$2"
config="$3"
# shellcheck disable=SC2034
xcode="$4"

function installFonts() {
    e_bold "Installing Fonts"
    mkdir -p "${HOME}/.fonts"
    for dir in fonts/*
    do
        fontname=$(basename "$dir")
        if [ -d "${HOME}/.fonts/${fontname}" ]
        then
            e_arrow "${fontname} is already installed"
        else
            cp -av "$dir" "${HOME}/.fonts" && e_success "Installed font: ${fontname}" || e_error "Unable to install font: ${fontname}"
        fi
    done
}

function installConfig() {
    e_bold "Installing Configuration Files"
    mkdir -p "${HOME}/.config"
    cp -av config/* "${HOME}/.config" && e_success "Installed config files" || e_error "Unable to install config files"
    mkdir -p "${HOME}/.local"
    cp -av local/* "${HOME}/.local" && e_success "Installed share files" || e_error "Unable to install share files"
    # fix the absolute path in qt5ct.conf
    sed -i -- "s:color_scheme_path=.*:color_scheme_path=${HOME}/.config/qt5ct/colors/one dark.conf:g" "${HOME}/.config/qt5ct/qt5ct.conf" && e_success "Updated QT5 config file" || e_error "Unable to update QT5 config file"
}

function isDebianDerivative() {
    which dpkg &> /dev/null
    return $?
}

function hasDebianPackage() {
    dpkg -s "$1" &> /dev/null
    return $?
}

function installDebianPackage() {
    isDebianDerivative || return
    if hasDebianPackage "$1"
    then
        e_success "$1 is already installed"
    else
        e_warning "Installing package $1"
        sudo apt-get install "$1"
        hasDebianPackage "$1" && e_success "$1 successfully installed" || e_error "$1 not installed"
    fi
}

function installDebianPackages() {
    isDebianDerivative || return
    e_bold "Installing Debian Packages"
    declare -a pkgs=(
        "arc-theme"
        "tango-icon-theme"
        "font-manager"
        "fonts-dancingscript"
        "fonts-ebgaramond"
        "fonts-ebgaramond-extra"
        "fonts-essays1743"
        "fonts-fantasque-sans"
        "fonts-goudybookletter"
        "fonts-humor-sans"
        "fonts-isabella"
        "fonts-lobster"
        "fonts-lobstertwo"
        "fonts-mononoki"
        "fonts-ubuntu"
        "ruby"
        "rake"
        "rails"
        "scite"
        "ttf-anonymous-pro"
        "ttf-xfree86-nonfree"
        "zenity"
    )
    for pkg in "${pkgs[@]}"
    do
        installDebianPackage "$pkg"
    done
}

function isRedHatDerivative() {
    which rpm &> /dev/null
    return $?
}

function installRedHatPackages() {
    isRedHatDerivative || return
    e_bold "Installing Red Hat Packages"
    ## TODO add packages here as needed
}

e_header "Linux Installer"

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
