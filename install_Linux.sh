#!/usr/bin/env bash

source ./bin/utils.sh

function installFonts() {
    e_bold "Installing Fonts"
    mkdir -p "${HOME}/.fonts"
    for dir in fonts; do
        cp -av $dir "${HOME}/.fonts"
    done
}

function installConfig() {
    e_bold "Installing Configuration Files"
    mkdir -p ${HOME}/.config
    cp -av config/* ${HOME}/.config && e_success "Installed config files" || e_error "Unable to install config files"
    mkdir -p ${HOME}/.local
    cp -av local/* ${HOME}/.local && e_success "Installed share files" || e_error "Unable to install share files"
    cp -av dircolors ${HOME}/.dircolors && e_success "Installed dircolors file" || e_error "Unable to install dircolors file"
}

e_header "Linux Installer"

installConfig
if [[ $fonts -eq 1 ]]; then
    installFonts
fi
