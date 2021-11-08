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
    if sed -i -- "s:color_scheme_path=.*:color_scheme_path=${HOME}/.config/qt5ct/colors/one dark.conf:g" "${HOME}/.config/qt5ct/qt5ct.conf"
    then
        g_success "Updated QT5 config file"
    else
        g_error "Unable to update QT5 config file"
    fi
    mkdir -p "${HOME}/.icons"
    for tarball in icons/*.tar.tgz
    do
        if tar -x -f "$tarball" -z -C "${HOME}/.icons"
        then
            g_success "Installed mouse cursor: $(basename -s .tar.gz "$tarball")"
        else
            g_error "Unable to install mouse cursor: $(basename -s .tar.gz "$tarball")"
        fi
    done
}

isDebianDerivative () {
    type -P dpkg &> /dev/null
    return $?
}

hasDebianPackage () {
    dpkg -s "$1" &> /dev/null
    return $?
}

installDebianPackage () {
    isDebianDerivative || return
    if ! hasDebianPackage "$1"
    then
        g_info "Installing package $1"
        sudo apt-get install "$1"
        hasDebianPackage "$1" && g_success "$1 successfully installed" || g_error "$1 not installed"
    fi
}

installDebianPackages () {
    isDebianDerivative || return
    g_bold "Installing Debian Packages"
    declare -a pkgs=(
        "2048-qt"
        "adb"
        "arc-theme"
        "atom"
        "atril"
        "audacious"
        "audacity"
        "bash-completion"
        "calibre"
        "catfish"
        "checkstyle"
        "cowsay"
        "cura"
        "dia"
        "doublecmd-qt"
        "engrampa"
        "exfalso"
        "feathernotes"
        "featherpad"
        "filezilla"
        "firefox-esr"
        "flameshot"
        "font-manager"
        "fontforge-doc"
        "fontforge-extras"
        "fontforge"
        "fortunes"
        "freecad-python3"
        "fritzing"
        "frozen-bubble"
        "galculator"
        "ghostwriter"
        "gimp-data-extras"
        "gimp-gutenprint"
        "gimp-help-en"
        "gimp-lensfun"
        "gimp-python"
        "gimp-texturize"
        "gimp"
        "gip"
        "git-doc"
        "git-extras"
        "git-flow"
        "git-lfs"
        "git"
        "gpick"
        "gramps"
        "htop"
        "imagemagick"
        "inkscape-open-symbols"
        "inkscape-tutorials"
        "inkscape"
        "jmol"
        "jupyter"
        "keepassx"
        "keepassxc"
        "krita"
        "less"
        "libreoffice"
        "logrotate"
        "lyx"
        "manpages-dev"
        "manpages"
        "meld"
        "meteo-qt"
        "mpg321"
        "nodejs"
        "openyahtzee"
        "pokerth"
        "projectlibre"
        "python3"
        "rails"
        "rake"
        "rclone"
        "rclone-browser"
        "ristretto"
        "rstudio"
        "rsync"
        "ruby"
        "scite"
        "sciteproj"
        "scribus-doc"
        "scribus-template"
        "scribus"
        "sigil"
        "snapd"
        "solaar"
        "speedtest-cli"
        "sqlite-doc"
        "sqlite"
        "sqlite3-doc"
        "sqlitebrowser"
        "synaptic"
        "tali"
        "tango-icon-theme"
        "texstudio"
        "texworks"
        "thunderbird"
        "ttf-xfree86-nonfree"
        "vim-addon-manager"
        "vim-airline"
        "vim-gtk"
        "vim"
        "vlc"
        "wget"
        "xcowsay"
        "xfburn"
        "xsane"
        "zenity"
    )
    declare -a fontpkgs=(
        "fonts-cabinsketch"
        "fonts-cantarell"
        "fonts-cardo"
        "fonts-comic-neue"
        "fonts-courier-prime"
        "fonts-croscore"
        "fonts-crosextra-caladea"
        "fonts-dancingscript"
        "fonts-dejavu"
        "fonts-droid-fallback"
        "fonts-ebgaramond"
        "fonts-ebgaramond-extra"
        "fonts-fantasque-sans"
        "fonts-fanwood"
        "fonts-freefont"
        "fonts-goudybookletter"
        "fonts-hack"
        "fonts-humor-sans"
        "fonts-inconsolata"
        "fonts-lato"
        "fonts-league-spartan"
        "fonts-liberation"
        "fonts-liberation2"
        "fonts-lindenhill"
        "fonts-linuxlibertine"
        "fonts-lobster"
        "fonts-lobstertwo"
        "fonts-mononoki"
        "fonts-noto-color-emoji"
        "fonts-noto-core"
        "fonts-noto-extra"
        "fonts-noto-mono"
        "fonts-noto-unhinted"
        "fonts-open-sans"
        "fonts-prociono"
        "fonts-quicksand"
        "fonts-roboto-slab"
        "fonts-roboto-unhinted"
        "fonts-texgyre"
        "fonts-ubuntu"
        "fonts-urw-base35"
        "ttf-anonymous-pro"
        "ttf-bitstream-vera"
    )
    # TODO replace ttf-anonymous-pro with fonts-anonymous-pro to the list above after upgrading to Debian bullseye
    pkgs+=( "${fontpkgs[@]}" ) # append font packages to list
    toInstall=()
    for pkg in "${pkgs[@]}"
    do
        if hasDebianPackage "$pkg"
        then
            g_success "$pkg is already installed"
            install=n
        elif [[ $yes -eq 1 ]]
        then
            install=y
        elif [[ $pkg == fonts-* ]] || [[ $pkg == ttf-* ]]
        then
            # Always install font packages
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
    if [[ ${#toInstall[@]} -gt 0 ]]
    then
        if [[ $gui -eq 1 ]]
        then
            zenity --info --text="Please return to the terminal to enter your password to allow software installation." \
                --window-icon=./installer.svg --width=300 --height=100
        fi
        for pkg in "${toInstall[@]}"
        do
            installDebianPackage "$pkg"
        done
        fc-cache
    fi
}

isRedHatDerivative () {
    type -P rpm &> /dev/null
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
