#!/usr/bin/env bash
# shellcheck disable=SC2034

# Use this script for any Intel/AMD-based specific installations

source ./bin/utils.sh

packages="$1"
fonts="$2"
config="$3"
xcode="$4"
gui="$5"
yes="$6"
debug="$7"
serveronly="$8"

INSTALLDIR=${TMPDIR:-/tmp}/dotfiles-installer
mkdir -p "$INSTALLDIR"
DOWNLOADS=${HOME}/Downloads
mkdir -p "$DOWNLOADS"
initial_wd=$PWD

installTarball () {
    tarball=$1
    basepath=$2
    tarpath=$3
    url=$4
    if [ -d "$basepath/$tarpath" ]
    then
        [[ $debug -eq 1 ]] && g_success "$tarball is already installed"
    else
        if [[ $yes -eq 1 ]]
        then
            install=y
        else
            if [[ $gui -eq 0 ]]
            then
                read -rp "Do you want to install ${C_FORE_BLUE}$tarpath${C_RESET}? [y/${C_BOLD}n${C_RESET}]: " install
            else
                zenity --question --text="Do you want to install ${tarpath}?" \
                    --window-icon=./installer.svg --width=300 --height=100 && install=y
            fi
        fi
        if [[ $install == "y" ]]
        then
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
    fi
}

installTarballs () {
    g_bold "Installing Tarballs"
    installTarball "free42linux.tar.gz" "/opt" "Free42Linux" "https://thomasokken.com/free42/download/Free42Linux.tgz"
}

hasFlatpak () {
    flatpak info "$1" &> /dev/null
    return $?
}

# TODO write function for update script to update all flatpaks when run (flatpak update)

installFlatpaks () {
    g_bold "Installing Flatpaks"
    declare -a flatpaks=(
        "com.getpostman.Postman"
        "com.github.alexkdeveloper.desktop-files-creator"
        "com.github.artemanufrij.regextester"
        "com.github.fabiocolacio.marker"
        "com.github.gijsgoudzwaard.image-optimizer"
        "com.github.junrrein.PDFSlicer"
        "com.github.muriloventuroso.pdftricks"
        "com.github.tchx84.Flatseal"
        "com.jetbrains.IntelliJ-IDEA-Community"
        "com.jetbrains.PyCharm-Community"
        "com.jetpackduba.Gitnuro"
        "com.poweriso.PowerISO"
        "com.syntevo.SmartGit"
        "com.syntevo.SmartSynchronize"
        "com.yacreader.YACReader"
        "fr.handbrake.ghb"
        "fr.rubet.rpn"
        "io.dbeaver.DBeaverCommunity"
        "io.github.arunsivaramanneo.GPUViewer"
        "io.github.seadve.Breathing"
        "io.github.trytonvanmeer.DungeonJournal"
        "org.gustavoperedo.FontDownloader"
        "re.sonny.OhMySVG"
    )
    # declare -a optionalFlatpaks=(
    #     "com.google.AndroidStudio"
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

getLatestGithubResource () {
    repo=$1
    search=$2
    githubDownload=$(wget -q -nv -O- https://api.github.com/repos/"${repo}"/releases/latest 2>/dev/null | jq -r ".assets[] | select(.name | test(\"${search}\")) | .browser_download_url")
}

installAppImages () {
    g_bold "Installing AppImages"
    declare -a urls=(
        "https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-linux.AppImage"
    )
    getLatestGithubResource "dail8859/NotepadNext" "x86_64.AppImage"
    urls+=("$githubDownload")
    local toInstall=()
    for url in "${urls[@]}"
    do
        filename=$(python3 "$initial_wd/get_url_file.py" "$url")
        if [ -x "${HOME}/bin/${filename}" ]
        then
            [[ $debug -eq 1 ]] && g_success "$filename is already installed"
            install=n
        elif [[ $yes -eq 1 ]]
        then
            install=y
        else
            if [[ $gui -eq 0 ]]
            then
                read -rp "Do you want to install AppImage ${C_FORE_BLUE}$filename${C_RESET}? [y/${C_BOLD}n${C_RESET}]: " install
            else
                zenity --question --text="Do you want to install AppImage ${filename}?" \
                    --window-icon=./installer.svg --width=300 --height=100 && install=y
            fi
        fi
        if [[ $install == "y" ]]
        then
            toInstall+=( "${url}" )
        fi
    done
    if [[ ${#toInstall[@]} -gt 0 ]]
    then
        for url in "${toInstall[@]}"
        do
            filename=$(python3 "$initial_wd/get_url_file.py" "$url")
            cd "$INSTALLDIR" && {
                wget -q "$url" -O "$filename"
                cp "$filename" "${HOME}/bin"
                chmod +x "${HOME}/bin/${filename}"
                # TODO extract .desktop and icon files from AppImage to add to system menu
                # - extract AppImage: "${HOME}/bin/${filename}" --appimage-extract
                # - cd squashfs-root (created in extraction)
                # - get .desktop file name
                # - pull icon file name from .desktop file
                # - check icon file in folder for extension
                # - if extension = svg
                # -   resolution="scalable"
                # - else
                # -   resolution=$(identify "$iconfile.*" | cut -f3 -d' ' | head -n 1)
                # - cp icon file to ${HOME}/.local/share/icons/hicolor/${resolution}/apps/
                # - replace Exec= line in .desktop file with "Exec=${HOME}/bin/${filename}" (expanded variables)
                # - copy .desktop file to ${HOME}/.local/share/applications
                # - cd ..
                # - rm -rf squashfs-root
            }
        done
    fi
}

downloadManualInstallers () {
    g_bold "Downloading Manual Installers"
    url=$(python3 "$initial_wd/get_html_href.py" https://www.anaconda.com/products/distribution | grep "Linux-x86_64\.sh" | head -n 1)
    filename=$(python3 "$initial_wd/get_url_file.py" "$url")
    if [ -e "${DOWNLOADS}/${filename}" ]
    then
        [[ $debug -eq 1 ]] && g_success "$filename has already been downloaded"
    else
        [[ $debug -eq 1 ]] && g_info "Downloading $url"
        wget -q --progress=dot:giga --show-progress "$url" -O "${DOWNLOADS}/${filename}"
        reportResult "Installer $filename has been downloaded to $HOME/Downloads" "Unable to download $filename"
    fi
}

if [[ $packages -eq 1 ]]
then
    installTarballs
    installFlatpaks
    installAppImages
    downloadManualInstallers
fi
