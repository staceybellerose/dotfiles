#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

source ./bin/utils.sh

arch=$(uname -s)
machinearch=$(uname -m)
TMPDIR=${TMPDIR:-/tmp}

packages=1
xcode=1
fonts=1
vscode=1
config=1

function help() {
    cat <<EOF
dotfiles installer - Stacey Adams - https://staceyadams.me/

Usage: $(basename "$0") [options]

Options:
  -h   Print this help text
  -c   Suppress configuration changes
  -f   Suppress font installation
  -p   Suppress package updates
  -v   Suppress VSCode extension installation
  -x   Suppress XCode initialization (OS X only)

Documentation can be found at https://github.com/staceybellerose/dotfiles

EOF
}

function installBashd() {
    e_bold "Installing bashd files"
    mkdir -p "${HOME}/.bashd"
    grep -q "extra.bashrc" "${HOME}/.bash_profile" &> /dev/null && e_arrow "bash profile already configured" || {
        echo '[ -f ~/.bashd/extra.bashrc ] && . ~/.bashd/extra.bashrc' >> "${HOME}/.bash_profile"
        e_success "bash profile configured"
    }
    grep -q "bash_profile" "${HOME}/.bashrc" &> /dev/null && e_arrow "bashrc already configured" || {
        echo '[ -n "$PS1" ] && source ~/.bash_profile' >> "${HOME}/.bashrc"
        e_success "bashrc configured"
    }
    cp -av bashd/* "${HOME}/.bashd" && e_success "Installed bashd files" || e_error "Unable to install bashd files"
}

function installVim() {
    e_bold "Installing vim files"
    mkdir -p "${HOME}/.vim"
    cp -av vim/* "${HOME}/.vim" && e_success "Installed vim files" || e_error "Unable to install vim files"
}

function installBin() {
    e_bold "Installing bin files"
    mkdir -p "${HOME}/bin"
    cp -av bin/* "${HOME}/bin" && e_success "Installed bin files" || e_error "Unable to install bin files"
}

function installOSBin() {
    [ -d "./bin_${arch}" ] && {
        e_bold "Installing OS-specific bin files"
        cp -av "./bin_${arch}/*" "${HOME}/bin" && e_success "Installed OS-specific bin files" || e_error "Unable to install OS-specific bin files"
        true
    } || e_warning "No OS-specific bin files to install"
}

function installConfig() {
    e_bold "Installing configuration files"
    cp -av editorconfig "${HOME}" && e_success "Installed editorconfig file" || e_error "Unable to install editorconfig file"
    cp -av dircolors "${HOME}/.dircolors" && e_success "Installed dircolors file" || e_error "Unable to install dircolors file"
}

e_header "Dotfiles Installer"

while getopts "h?cfpvx" opt
do
    case $opt in
        h|\?)
            help
            exit 0
            ;;
        c)
            config=0
            ;;
        f)
            fonts=0
            ;;
        p)
            packages=0
            ;;
        v)
            vscode=0
            ;;
        x)
            xcode=0
            ;;
        *)
            help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

installBashd
installBin
installOSBin
installVim
if [[ $config -eq 1 ]]
then
    installConfig
fi
if [[ $vscode -eq 1 ]]
then
    . ./install_vscode_extensions.sh
fi

# Process OS-specific files
[ -f "./install_${arch}.sh" ] && . "./install_${arch}.sh" $packages $fonts $config $xcode
[ -f "./install_${arch}_${machinearch}.sh" ] && . "./install_${arch}_${machinearch}.sh" $packages $fonts $config $xcode
e_success "Done!"
exit 0
