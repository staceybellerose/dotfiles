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
serveronly="$8"

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
    for dir in "$initial_wd"/fonts/*
    do
        if [ -d "$dir" ]
        then
            fontname=$(basename "$dir")
            if [[ $serveronly -ne 1 || -e "$dir/.serverallowed" ]]
            then
                if fc-list | grep -q "$fontname"
                then
                    [[ $debug -eq 1 ]] && g_success "${fontname} is already installed"
                else
                    cp $CPOPT "$dir" "${HOME}/.fonts"
                    reportResult "Installed font: ${fontname}" "Unable to install font: ${fontname}"
                fi
            else
                [[ $debug -eq 1 ]] && g_warning "skipping ${fontname}: not tagged as server font"
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
    dpkg-query -W -f='${Status}' "$1" | grep -P '(?<!not-)installed' &> /dev/null
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
            echo "deb-src http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" | sudo tee -a "$sources/debian-backports.list"
        fi
    fi

    # Add GitHub CLI source
    if [ ! -e "$sources/github-cli.list" ]
    then
        wget -q https://cli.github.com/packages/githubcli-archive-keyring.gpg -O- | sudo gpg --dearmor -o "$keyrings/githubcli-archive-keyring.gpg"
        echo "deb [arch=$(dpkg --print-architecture)] https://cli.github.com/packages stable main" | sudo tee "$sources/github-cli.list"
    fi
    deb_extra_packages+=( "gh" )

    # Add Beekeeper Studio source
    if [[ $serveronly -ne 1 ]]
    then
        if [ ! -e "$sources/beekeeper-studio-app.list" ]
        then
            wget -q https://deb.beekeeperstudio.io/beekeeper.key -O- | sudo gpg --dearmor -o "$keyrings/beekeeper-studio-keyring.gpg"
            echo "deb https://deb.beekeeperstudio.io stable main" | sudo tee "$sources/beekeeper-studio-app.list"
        fi
        deb_extra_packages+=( "beekeeper-studio" )

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
    fi

    # Update list of sources
    sudo apt-get -q update &> "$out"
}

installDebianPackages () {
    isDebianDerivative || return
    g_bold "Installing Debian Packages"
    declare -a desktoppkgs=(
        "2048-qt"
        "adb"
        "arduino"
        "atril"
        "audacious"
        "audacity"
        "calibre"
        "catfish"
        "checkstyle"
        "cura"
        "dia"
        "engrampa"
        "exfalso"
        "flameshot"
        "flatpak"
        "fontforge-doc"
        "fontforge-extras"
        "fontforge"
        "freecad-python3"
        "fritzing"
        "frozen-bubble"
        "ghostwriter"
        "gimp-data-extras"
        "gimp-gutenprint"
        "gimp-help-en"
        "gimp-lensfun"
        "gimp-python"
        "gimp-texturize"
        "gimp"
        "gpick"
        "gramps"
        "inkscape-open-symbols"
        "inkscape-tutorials"
        "inkscape"
        "jmol"
        "krita"
        "libreoffice"
        "lyx"
        "meteo-qt"
        "mpg321"
        "openyahtzee"
        "paulstretch"
        "pencil"
        "pokerth"
        "projectlibre"
        "qdirstat"
        "ristretto"
        "scite"
        "sciteproj"
        "scribus-doc"
        "scribus-template"
        "scribus"
        "sigil"
        "solaar"
        "tali"
        "texstudio"
        "thunderbird"
        "vlc"
        "xaos"
        "xcowsay"
        "xfburn"
        "xsane"
    )
    declare -a pkgs=(
        "ack"
        "arc-theme"
        "autoconf"
        "automake"
        "bison"
        "gawk"
        "bash-completion"
        "build-essential"
        "cowsay"
        "curl"
        "davfs2"
        "diffuse"
        "doublecmd-qt"
        "feathernotes"
        "featherpad"
        "filezilla"
        "firefox-esr"
        "font-manager"
        "fortunes"
        "fuse"
        "fuseiso9660"
        "galculator"
        "gip"
        "git-doc"
        "git-extras"
        "git-flow"
        "git-lfs"
        "git"
        "gitg"
        "github-backup"
        "htop"
        "imagemagick"
        "jekyll"
        "jq"
        "jupyter"
        "keepassx"
        "keepassxc"
        "less"
        "logrotate"
        "manpages-dev"
        "manpages"
        "meld"
        "mugshot"
        "net-tools"
        "nodejs"
        "python3"
        "python3-gpg"
        "qemu"
        "rails"
        "rake"
        "rclone"
        "rclone-browser"
        "rfkill"
        "rsnapshot"
        "rsync"
        "ruby"
        "ruby-dev"
        "speedtest-cli"
        "sqlite3"
        "sqlite3-doc"
        "sqlitebrowser"
        "synaptic"
        "tango-icon-theme"
        "tldr"
        "vim-addon-manager"
        "vim-airline"
        "vim-gtk"
        "vim"
        "webhttrack"
        "wget"
        "wireless-tools"
        "zenity"
        "fonts-lato"
        "fonts-roboto-slab"
        "fonts-roboto-unhinted"
        "fonts-texgyre"
        "fonts-urw-base35"
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
        "fonts-ubuntu"
        "ttf-bitstream-vera"
    )
    declare -a pkgsv10=(
        "ttf-anonymous-pro"
        "sqlite-doc"
        "sqlite"
    )
    declare -a pkgsv11=(
        "fonts-anonymous-pro"
        "fonts-cascadia-code"
        "free42-nologo"
    )
    if [[ $VERSION_ID -eq 10 ]]
    then
        pkgs+=( "${pkgsv10[@]}" ) # append packages for Debian 10
    elif [[ $VERSION_ID -ge 11 ]]
    then
        pkgs+=( "${pkgsv11[@]}" ) # append packages for Debian 11+
    fi
    if [[ $serveronly -ne 1 ]]
    then
        pkgs+=( "${desktoppkgs[@]}" ) # append desktop packages
        pkgs+=( "${fontpkgs[@]}" ) # append font packages to list
    fi
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

getLatestGithubResource () {
    repo=$1
    search=$2
    githubDownload=$(wget -q -nv -O- https://api.github.com/repos/"${repo}"/releases/latest 2>/dev/null | jq -r ".assets[] | select(.name | test(\"${search}\")) | .browser_download_url")
}

#TODO write script to manually update these packages (except for those that add themselves as repositories, e.g. chrome)

installDebianExternalPackages () {
    isDebianDerivative || return
    arch=$(dpkg --print-architecture)

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

	if [[ $serveronly -ne 1 ]]
	then

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

    # Discord
    hasDebianPackage "discord" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package discord"
            cd "$INSTALLDIR" && {
                wget -q "https://discord.com/api/download?platform=linux&format=deb" -O discord-latest.deb
                sudo apt-get -q install "$INSTALLDIR/discord-latest.deb"
            }
        fi
    }

    # Mega
    hasDebianPackage "megasync" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package megasync"
            url1=""
            url2=""
            url3=""
            if [ "$VERSION_ID" = "10" ]
            then
                url1="https://mega.nz/linux/repo/Debian_10.0/amd64/megasync-Debian_10.0_amd64.deb"
                url2="https://mega.nz/linux/repo/Debian_10.0/amd64/thunar-megasync-Debian_10.0_amd64.deb"
                url3="https://mega.nz/linux/repo/Debian_10.0/amd64/megacmd-Debian_10.0_amd64.deb"
            elif [ "$VERSION_ID" = "11" ]
            then
                url1="https://mega.nz/linux/repo/Debian_11/amd64/megasync-Debian_11_amd64.deb"
                url2="https://mega.nz/linux/repo/Debian_11/amd64/thunar-megasync-Debian_11_amd64.deb"
                url3="https://mega.nz/linux/repo/Debian_11/amd64/megacmd-Debian_11_amd64.deb"
            fi
            if [ -n "$url1" ] && [ -n "$url2" ] && [ -n "$url3" ]
            then
                cd "$INSTALLDIR" && {
                    wget -q "$url1" -O megasync-latest.deb
                    sudo apt-get -q install "$INSTALLDIR/megasync-latest.deb"
                    wget -q "$url2" -O thunar-megasync.deb
                    sudo apt-get -q install "$INSTALLDIR/thunar-megasync.deb"
                    wget -q "$url3" -O megacmd-latest.deb
                    sudo apt-get -q install "$INSTALLDIR/megacmd-latest.deb"
                }
            fi
        fi
    }

    # ProjectLibre
    hasDebianPackage "projectlibre" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package projectlibre"
            cd "$INSTALLDIR" && {
                wget -q -nv -O projectlibre-release.json "https://sourceforge.net/projects/projectlibre/best_release.json"
                mimetype=$(jq -r ".platform_releases.linux.mime_type" projectlibre-release.json)
                if [[ $mimetype =~ "application/x-debian-package" ]]
                then
                    url=$(jq -r ".platform_releases.linux.url" projectlibre-release.json)
                    wget -q "$url" -O projectlibre.deb
                    sudo apt-get -q install "$INSTALLDIR/projectlibre.deb"
                else
                    e_error "Unable to locate DEB file for ProjectLibre - skipping installation"
                fi
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

    # PDF Booklet
    hasDebianPackage "pdfbooklet" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package pdfbooklet"
            cd "$INSTALLDIR" && {
                url=$(python3 "$initial_wd/get_html_href.py" https://pdfbooklet.sourceforge.io/wordpress/download/ | grep "\.deb" | head -n 1)
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }

    # Pencil Project
    hasDebianPackage "pencil" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package pencil"
            cd "$INSTALLDIR" && {
                url=$(python3 "$initial_wd/get_html_href.py" https://pencil.evolus.vn/Downloads.html | grep "amd64\.deb" | head -n 1)
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }

    # duf (Disk Usage/Free Utility)
    hasDebianPackage "duf" || {
        if [ "$arch" = "amd64" ] || [ "$arch" = "arm64" ]
        then
            g_info "Installing package duf"
            cd "$INSTALLDIR" && {
                getLatestGithubResource "muesli/duf" "linux_${arch}.deb"
                url=$githubDownload
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }

    # Advanced REST Client
    hasDebianPackage "advanced-rest-client" || {
        if [ "$arch" = "amd64" ]
        then
            g_info "Installing package advanced-rest-client"
            cd "$INSTALLDIR" && {
                getLatestGithubResource "advanced-rest-client/arc-electron" "linux.+amd64.deb"
                url=$githubDownload
                filename=$(python3 "$initial_wd/get_url_file.py" "$url")
                wget -q "$url"
                sudo apt-get -q install "$INSTALLDIR/$filename"
            }
        fi
    }
    fi
}

isRedHatDerivative () {
    type -P rpm &> /dev/null
    return $?
}

installRedHatPackages () {
    isRedHatDerivative || return
    g_error "Unable to install Red Hat packages - don't know how"
    # TODO add logic here as needed if I switch to Red Hat-based systems
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
fi
if [[ $fonts -eq 1 ]]
then
    installFonts
fi

cd "$initial_wd" && rm -rf "$INSTALLDIR"
