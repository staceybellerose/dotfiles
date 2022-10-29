#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2024

# Use this script for any Linux-based specific installations

source ./bin/utils.sh

packages="$1"
fonts="$2"
config="$3"
# shellcheck disable=SC2034
xcode="$4"
gui="$5"
yes="$6"
debug="$7"

if [[ $gui -eq 0 ]]
then
    if [[ $debug -eq 0 ]]
    then
        CPOPT=-a
    else
        CPOPT=-av
    fi
else
    CPOPT=-a
fi

INSTALLDIR=${TMPDIR:-/tmp}/dotfiles-installer
mkdir -p "$INSTALLDIR"
initial_wd=$PWD
if [[ $debug -eq 0 ]]
then
    out=/dev/null
else
    out=/dev/stdout
fi

declare -a deb_extra_packages=()

installFonts () {
    g_bold "Installing Fonts"
    mkdir -p "${HOME}/.fonts"
    for dir in fonts/*
    do
        if [ -d "$dir" ]
        then
            fontname=$(basename "$dir")
            if fc-list | grep -q "$fontname"
            then
                [[ $debug -eq 1 ]] && g_success "${fontname} is already installed"
            else
                cp $CPOPT "$dir" "${HOME}/.fonts"
                reportResult "Installed font: ${fontname}" "Unable to install font: ${fontname}"
            fi
        fi
    done
    fc-cache
}

installConfig () {
    g_bold "Installing Configuration Files"
    mkdir -p "${HOME}/.config"
    cp $CPOPT config/* "${HOME}/.config"
    reportResult "Installed config files" "Unable to install config files"
    mkdir -p "${HOME}/.local"
    cp $CPOPT local/* "${HOME}/.local"
    reportResult "Installed share files" "Unable to install share files"
    # fix the absolute path in qt5ct.conf
    if sed -i -- "s:color_scheme_path=.*:color_scheme_path=${HOME}/.config/qt5ct/colors/one dark.conf:g" "${HOME}/.config/qt5ct/qt5ct.conf"
    then
        g_success "Updated QT5 config file"
    else
        g_error "Unable to update QT5 config file"
    fi
    mkdir -p "${HOME}/.icons"
    for tarball in icons/*.tar.gz
    do
        if tar -x -f "$tarball" -z -C "${HOME}/.icons"
        then
            g_success "Installed mouse cursor: $(basename -s .tar.gz "$tarball")"
        else
            g_error "Unable to install mouse cursor: $(basename -s .tar.gz "$tarball")"
        fi
    done
}

promptForPassword () {
    if [[ $gui -eq 1 ]]
    then
        zenity --info --text="Please return to the terminal to enter your password to allow software installation." \
            --window-icon=./installer.svg --width=300 --height=100
    fi
}

isDebianDerivative () {
    type -P dpkg &> /dev/null
    return $?
}

hasDebianPackage () {
    dpkg-query -W -f='${Status}' "$1" | grep 'installed' &> /dev/null
    return $?
}

installDebianPackage () {
    isDebianDerivative || return
    if ! hasDebianPackage "$1"
    then
        g_info "Installing package $1"
        sudo apt-get -q install "$1"
        hasDebianPackage "$1"
        reportResult "$1 successfully installed" "$1 not installed"
    fi
}

configureDebian () {
    isDebianDerivative || return

    arch=$(dpkg --print-architecture)
    source /etc/os-release

    isRaspberryPi=0
    if [ "$arch" = "arm64" ] || [ "$arch" = "armhf" ]
    then
        if grep -q "BCM(283(5|6|7)|270(8|9)|2711)" /proc/cpuinfo &> /dev/null
        then
            isRaspberryPi=1
        fi
    fi

    promptForPassword
    installDebianPackage "wget"

    keyrings=/etc/apt/trusted.gpg.d
    sources=/etc/apt/sources.list.d

    # Add Backports source for amd64 (x86_64) only
    if [ "$arch" = "amd64" ]
    then
        if [ ! -e "$sources/debian-backports.list" ]
        then
            echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" | sudo tee "$sources/debian-backports.list"
        fi
    fi

    # Add Beekeeper Studio source
    if [ ! -e "$sources/beekeeper-studio-app.list" ]
    then
        wget -q https://deb.beekeeperstudio.io/beekeeper.key -O- | sudo gpg --dearmor -o "$keyrings/beekeeper-studio-keyring.gpg"
        echo "deb https://deb.beekeeperstudio.io stable main" | sudo tee "$sources/beekeeper-studio-app.list"
    fi
    deb_extra_packages+=( "beekeeper-studio" )

    # Add GitHub CLI source
    if [ ! -e "$sources/github-cli.list" ]
    then
        wget -q https://cli.github.com/packages/githubcli-archive-keyring.gpg -O- | sudo gpg --dearmor -o "$keyrings/githubcli-archive-keyring.gpg"
        echo "deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main" | sudo tee "$sources/github-cli.list"
    fi
    deb_extra_packages+=( "gh" )

    # Add Spotify source
    if [ "$arch" = "amd64" ]
    then
        if [ ! -e "$sources/spotify.list" ]
        then
            wget -q https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg -O- | sudo apt-key add -
            echo "deb http://repository.spotify.com stable non-free" | sudo tee "$sources/spotify.list"
        fi
        deb_extra_packages+=( "spotify-client" )
    fi

    # Set up Steam
    if [ "$arch" = "amd64" ]
    then
        sudo dpkg --add-architecture i386 &> "$out"
        sudo apt-get -q update &> "$out"
        installDebianPackage "software-properties-common"
        sudo add-apt-repository contrib &> "$out"
        sudo add-apt-repository non-free &> "$out"
        deb_extra_packages+=( "steam" )
    fi

    # Add VirtualBox source
    if [ "$arch" = "amd64" ]
    then
        if [ ! -e "$sources/virtualbox.list" ]
        then
            wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o "$keyrings/virtualbox-keyring.gpg"
            echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $VERSION_CODENAME contrib" | sudo tee "$sources/virtualbox.list"
        fi
        deb_extra_packages+=( "virtualbox-6.1" )
    fi

    # Set up VS Code source
    if [ "$arch" = "amd64" ]
    then
        if [ ! -e "$sources/vscode.list" ]
        then
            wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo gpg --dearmor -o "$keyrings/microsoft-packages-keyring.gpg"
            echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" | sudo tee "$sources/vscode.list"
        fi
        deb_extra_packages+=( "code" )
    elif [ "$isRaspberryPi" = "1" ]
    then
        # VS Code is set up in the standard Raspberry Pi package repository
        deb_extra_packages+=( "code" )
    fi

    # Add WineHQ source
    if [ "$arch" = "amd64" ]
    then
        if [ ! -e "$sources/winehq.list" ]
        then
            wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
            echo "deb https://dl.winehq.org/wine-builds/debian/ ${VERSION_CODENAME} main" | sudo tee "$sources/winehq.list"
        fi
        deb_extra_packages+=( "winehq-stable" )
    fi

    # Add YACReader source
    if [ ! -e "$sources/home:selmf.list" ]
    then
        if [ "$arch" = "amd64" ]
        then
            name="Debian"
        elif [ "$isRaspberryPi" = 1 ]
        then
            name="Raspbian"
        else
            name="?"
        fi
        if [ "$name" != "?" ]
        then
            wget -q "https://download.opensuse.org/repositories/home:selmf/${name}_${VERSION_ID}/Release.key" -O- | sudo gpg --dearmor -o "$keyrings/home_selmf.gpg"
            echo "deb http://download.opensuse.org/repositories/home:/selmf/${name}_${VERSION_ID}/ /" | sudo tee "$sources/home:selmf.list"
        fi
    fi
    deb_extra_packages+=( "yacreader" )

    # Update list of sources
    sudo apt-get -q update &> "$out"
}

installDebianPackages () {
    isDebianDerivative || return
    g_bold "Installing Debian Packages"
    declare -a pkgs=(
        "2048-qt"
        "ack"
        "adb"
        "arc-theme"
        "arduino"
        "atril"
        "audacious"
        "audacity"
        "bash-completion"
        "calibre"
        "catfish"
        "checkstyle"
        "cowsay"
        "cura"
        "davfs2"
        "dia"
        "diffuse"
        "doublecmd-qt"
        "engrampa"
        "exfalso"
        "feathernotes"
        "featherpad"
        "filezilla"
        "firefox-esr"
        "flameshot"
        "flatpak"
        "font-manager"
        "fontforge-doc"
        "fontforge-extras"
        "fontforge"
        "fortunes"
        "freecad-python3"
        "fritzing"
        "frozen-bubble"
        "fuse"
        "fuseiso9660"
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
        "gitg"
        "github-backup"
        "gpick"
        "gramps"
        "htop"
        "imagemagick"
        "inkscape-open-symbols"
        "inkscape-tutorials"
        "inkscape"
        "jekyll"
        "jmol"
        "jq"
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
        "mugshot"
        "nodejs"
        "openyahtzee"
        "pencil"
        "pokerth"
        "projectlibre"
        "python3"
        "qdirstat"
        "rails"
        "rake"
        "rclone"
        "rclone-browser"
        "ristretto"
        "rsnapshot"
        "rstudio"
        "rsync"
        "ruby"
        "scite"
        "sciteproj"
        "scribus-doc"
        "scribus-template"
        "scribus"
        "sigil"
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
        "thunderbird"
        "tldr"
        "vim-addon-manager"
        "vim-airline"
        "vim-gtk"
        "vim"
        "vlc"
        "webhttrack"
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
        "fonts-cmu"
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
        "fonts-freefont-ttf"
        "fonts-goudybookletter"
        "fonts-hack"
        "fonts-humor-sans"
        "fonts-inconsolata"
        "fonts-jura"
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
        "fonts-oxygen"
        "fonts-paratype"
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
    # TODO add "fonts-cascadia-code" to the list above after upgrading to Debian bullseye
    # TODO replace ttf-anonymous-pro with fonts-anonymous-pro to the list above after upgrading to Debian bullseye
    pkgs+=( "${fontpkgs[@]}" ) # append font packages to list
    pkgs+=( "${deb_extra_packages[@]}" ) # append extra packages to list
    toInstall=()
    for pkg in "${pkgs[@]}"
    do
        if hasDebianPackage "$pkg"
        then
            [[ $debug -eq 1 ]] && g_success "$pkg is already installed"
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
        for pkg in "${toInstall[@]}"
        do
            installDebianPackage "$pkg"
        done
        fc-cache
    fi
}

installDebianExternalPackages () {
    isDebianDerivative || return
    arch=$(dpkg --print-architecture)

    # Google Chrome
    if [ "$arch" = "amd64" ]
    then
        hasDebianPackage "google-chrome-stable" || {
            g_info "Installing package google-chrome-stable"
            cd "$INSTALLDIR" && {
                wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
                sudo apt-get -q install "$INSTALLDIR/google-chrome-stable_current_amd64.deb"
            }
        }
    fi

    # Dropbox
    hasDebianPackage "dropbox" || {
        if [[ "$arch" = "amd64" || "$arch" = "i386" ]]
        then
            g_info "Installing package dropbox"
            cd "$INSTALLDIR" && {
                url=$(python3 "$initial_wd/get_html_href.py" https://linux.dropbox.com/packages/debian/ | grep "\.deb$" | grep "$arch" | tail -1)
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }

    # # GitKraken
    # hasDebianPackage "gitkraken" || {
    #     if [ "$arch" = "amd64" ]
    #     then
    #         g_info "Installing package gitkraken"
    #         cd "$INSTALLDIR" && {
    #             wget -q https://release.gitkraken.com/linux/gitkraken-amd64.deb
    #             sudo apt-get -q install "$INSTALLDIR/gitkraken-amd64.deb"
    #         }
    #     fi
    # }

    # Raspberry Pi Imager
    hasDebianPackage "rpi-imager" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package rpi-imager"
            cd "$INSTALLDIR" && {
                wget -q https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb
                sudo apt-get -q install "$INSTALLDIR/imager_latest_amd64.deb"
            }
        fi
    }

    # DeepGit
    hasDebianPackage "deepgit" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package deepgit"
            cd "$INSTALLDIR" && {
                url=$(python3 "$initial_wd/get_html_href.py" https://www.syntevo.com/deepgit/download/ | grep "\.deb$" | head -n 1)
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }

    # RStudio
    hasDebianPackage "rstudio" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package rstudio"
            cd "$INSTALLDIR" && {
                url=$(python3 "$initial_wd/get_html_href.py" https://www.rstudio.com/products/rstudio/download/ | grep "\.deb$" | head -n 1)
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }
}

isRedHatDerivative () {
    type -P rpm &> /dev/null
    return $?
}

hasRedHatPackage () {
    ## TODO fix this once running a RedHat-based system
    false
}

installRedHatPackage () {
    isRedHatDerivative || return
    if ! hasRedHatPackage "$1"
    then
        ## TODO add logic here to install package
        g_error "Unable to install $1 - don't know how"
    fi
}

installRedHatPackages () {
    isRedHatDerivative || return
    g_bold "Installing Red Hat Packages"
    ## TODO add packages here as needed
}

installRvm () {
    type rvm &> /dev/null || {
        # rvm is dependent on curl
        isDebianDerivative && {
            installDebianPackage "curl"
            installDebianPackage "gpg"
        }
        isRedHatDerivative && {
            installRedHatPackage "curl"
            installRedHatPackage "gpg"
        }
        cd "$INSTALLDIR" && {
            curl -fsSL https://rvm.io/mpapis.asc | gpg -q --import -
            curl -fsSL https://rvm.io/pkuczynski.asc | gpg -q --import -
            curl -fsSL https://get.rvm.io -o rvm-installer && bash -- rvm-installer stable --ruby --rails --quiet-curl
        }
    }
}

installTarball () {
    # TODO prompt before installing!
    tarball=$1
    basepath=$2
    tarpath=$3
    url=$4
    if [ -d "$basepath/$tarpath" ]
    then
        [[ $debug -eq 1 ]] && g_success "$tarball is already installed"
    else
        cd "$INSTALLDIR" && {
            wget -q "$url" -O "$tarball"
            if sudo tar -x -f "$tarball" -z -C "$basepath" --owner=root --group=root
            then
                sudo chown -R root:root "$basepath/$tarpath"
                g_success "Installed tarball: $tarball"
            else
                g_error "Unable to install tarball: $tarball"
            fi
        }
    fi
}

installTarballs () {
    g_bold "Installing Tarballs"
    installTarball "free42linux.tar.gz" "/opt" "Free42Linux" "https://thomasokken.com/free42/download/Free42Linux.tgz"
    installTarball "postman-latest.tar.gz" "/opt" "Postman" "https://dl.pstmn.io/download/latest/linux64"
}

hasFlatpak () {
    flatpak info "$1" &> /dev/null
    return $?
}

installFlatpaks () {
    g_bold "Installing Flatpaks"
    declare -a flatpaks=(
        "com.github.alexkdeveloper.desktop-files-creator"
        "com.github.artemanufrij.regextester"
        "com.github.gijsgoudzwaard.image-optimizer"
        "com.google.AndroidStudio"
        "com.jetbrains.IntelliJ-IDEA-Community"
        "com.jetbrains.PyCharm-Community"
        "io.github.seadve.Breathing"
        "io.github.trytonvanmeer.DungeonJournal"
        "re.sonny.OhMySVG"
    )
    # declare -a optionalFlatpaks=(
    #     "us.zoom.Zoom"
    # )
    type flatpak &> /dev/null && {
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        local toInstall=()
        for pkg in "${flatpaks[@]}"
        do
            if hasFlatpak "$pkg"
            then
                [[ $debug -eq 1 ]] && g_success "$pkg (flatpak) is already installed"
                install=n
            elif [[ $yes -eq 1 ]]
            then
                install=y
            else
                if [[ $gui -eq 0 ]]
                then
                    read -rp "Do you want to install flatpak ${C_FORE_BLUE}$pkg${C_RESET}? [y/${C_BOLD}n${C_RESET}]: " install
                else
                    zenity --question --text="Do you want to install flatpak ${pkg}?" \
                        --window-icon=./installer.svg --width=300 --height=100 && install=y
                fi
            fi
            if [[ $install == "y" ]]
            then
                toInstall+=( "${pkg}" )
            fi
        done
        if [[ ${#toInstall[@]} -gt 0 ]]
        then
            for pkg in "${toInstall[@]}"
            do
                hasFlatpak "$pkg" || {
                    g_info "Installing flatpak $pkg"
                    flatpak install -y flathub "$pkg"
                    hasFlatpak "$pkg"
                    reportResult "$pkg flatpack successfully installed" "$pkg flatpak not installed"
                }
            done
        fi
    }
}

g_header "Linux Installer"

if [[ $config -eq 1 ]]
then
    installConfig
fi
if [[ $packages -eq 1 ]]
then
    isDebianDerivative && {
        configureDebian
        installDebianPackages
        installDebianExternalPackages
    }
    isRedHatDerivative && installRedHatPackages
    installRvm
    installTarballs
    installFlatpaks
fi
if [[ $fonts -eq 1 ]]
then
    installFonts
fi

cd "$initial_wd" && rm -rf "$INSTALLDIR"
