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
    for dir in fonts; do
        cp -av $dir "${HOME}/.fonts"
    done
}

function installConfig() {
    e_bold "Installing Configuration Files"
    mkdir -p "${HOME}/.config"
    cp -av config/* "${HOME}/.config" && e_success "Installed config files" || e_error "Unable to install config files"
    mkdir -p "${HOME}/.local"
    cp -av local/* "${HOME}/.local" && e_success "Installed share files" || e_error "Unable to install share files"
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
