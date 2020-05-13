#!/bin/bash

source ./bin/utils.sh

function installFonts() {
    e_bold "Installing Fonts"
    mkdir -p "${HOME}/.fonts"
    for dir in fonts; do
        cp -a $dir "${HOME}/.fonts"
    done
}

function installConfig() {
    e_bold "Installing Configuration Files"
    mkdir -p ${HOME}/.config
    cp -a config/* ${HOME}/.config && e_success "Installed config files" || e_error "Unable to install config files"
    mkdir -p ${HOME}/.local
    cp -a local/* ${HOME}/.local && e_success "Installed share files" || e_error "Unable to install share files"
}

e_header "Linux Installer"

installConfig
installFonts

exit 0
