#!/usr/bin/env bash
# shellcheck disable=SC1090

source ./bin/utils.sh

arch=$(uname -s)
machinearch=$(uname -m)
TMPDIR=${TMPDIR:-/tmp}

setXcode () {
    # Don't run the xcode options unless on a Mac
    if [[ "${arch}" == "Darwin" ]]
    then
        xcode=1
    else
        xcode=0
    fi
}

android=0
gui=0
packages=1
fonts=1
vscode=1
config=1
only=0
yes=0
debug=0 # hidden option
setXcode

CPOPT=-av

help () {
    cat <<EOF
dotfiles installer - Stacey Adams - https://staceyadams.me/

Usage: $(basename "$0") [ options ]

Options:
  -h   Print this help text
  -g   Run in GUI mode (requires zenity in \$PATH)
  -y   Answer Yes to all prompts
  -a   Enable Android Studio configuration changes
  -c   Suppress configuration changes
  -f   Suppress font installation
  -p   Suppress package updates
  -v   Suppress VSCode extension installation
  -x   Suppress XCode initialization (OS X only)
  -C   Only run configuration changes
  -F   Only run font installation
  -P   Only run package updates
  -V   Only run VSCode extension installation
  -X   Only run XCode initialization (OS X only)

If multiple captial letter options are used, only the last one in the command
line will take effect. The other capital letter options are ignored.

EOF
}

installBashd () {
    g_bold "Installing bashd files"
    mkdir -p "${HOME}/.bashd"
    if grep -q "extra.bashrc" "${HOME}/.bash_profile" &> /dev/null
    then
        [[ $debug -eq 1 ]] && g_success "bash profile is already configured"
    else
        echo '[ -f ~/.bashd/extra.bashrc ] && source ~/.bashd/extra.bashrc' >> "${HOME}/.bash_profile"
        g_success "bash profile configured"
    fi
    if grep -q "bash_profile" "${HOME}/.bashrc" &> /dev/null
    then
        [[ $debug -eq 1 ]] && g_success "bashrc is already configured"
    else
        # shellcheck disable=SC2016
        echo '[ -n "$PS1" ] && source ~/.bash_profile' >> "${HOME}/.bashrc"
        g_success "bashrc configured"
    fi
    if [[ $android -eq 1 ]]
    then
        if grep -q "extra_androidSdk.bashrc" "${HOME}/.bash_profile" &> /dev/null
        then
            [[ $debug -eq 1 ]] && g_success "bash profile is already configured for Android Studio"
        else
            echo '[ -f ~/.bashd/extra_androidSdk.bashrc ] && source ~/.bashd/extra_androidSdk.bashrc' >> "${HOME}/.bash_profile"
            g_success "bash profile configured for Android Studio"
        fi
    fi
    cp $CPOPT bashd/* "${HOME}/.bashd"
    reportResult "Installed bashd files" "Unable to install bashd files"
}

installVim () {
    g_bold "Installing vim files"
    mkdir -p "${HOME}/.vim"
    cp $CPOPT vim/* "${HOME}/.vim"
    reportResult "Installed vim files" "Unable to install vim files"
}

installBin () {
    g_bold "Installing bin files"
    mkdir -p "${HOME}/bin"
    cp $CPOPT bin/* "${HOME}/bin"
    reportResult "Installed bin files" "Unable to install bin files"
}

installOSBin () {
    if [ -d "./bin_${arch}" ]
    then
        g_bold "Installing OS-specific bin files"
        cp $CPOPT "./bin_${arch}/*" "${HOME}/bin"
        reportResult "Installed OS-specific bin files" "Unable to install OS-specific bin files"
        true
    else
      g_info "No OS-specific bin files to install"
    fi
}

installConfig () {
    g_bold "Installing configuration files"
    cp $CPOPT editorconfig "${HOME}"
    reportResult "Installed editorconfig file" "Unable to install editorconfig file"
    cp $CPOPT dircolors "${HOME}/.dircolors"
    reportResult "Installed dircolors file" "Unable to install dircolors file"
}

header="$(basename "$0") - Dotfiles Installer"

while getopts "h?adgcfpvxyCFPVX" opt
do
    case $opt in
        h|\?)
            help
            exit 0
            ;;
        d)
            debug=1
            ;;
        a)
            android=1
            ;;
        g)
            if command -v zenity &> /dev/null
            then
                gui=1
            fi
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
        y)
            yes=1
            ;;
        C)
            packages=0
            xcode=0
            fonts=0
            vscode=0
            config=1
            only=1
            ;;
        F)
            packages=0
            xcode=0
            fonts=1
            vscode=0
            config=0
            only=1
            ;;
        P)
            packages=1
            xcode=0
            fonts=0
            vscode=0
            config=0
            only=1
            ;;
        V)
            packages=0
            xcode=0
            fonts=0
            vscode=1
            config=0
            only=1
            ;;
        X)
            packages=0
            xcode=1
            fonts=0
            vscode=0
            config=0
            setXcode
            ;;
        *)
            help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

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

if [[ $gui -eq 1 && $yes -eq 0 ]]
then
    if [[ $config -eq 1 ]] ; then boolconfig=TRUE ; else boolconfig=FALSE ; fi
    if [[ $fonts -eq 1 ]] ; then boolfonts=TRUE ; else boolfonts=FALSE ; fi
    if [[ $packages -eq 1 ]] ; then boolpackages=TRUE ; else boolpackages=FALSE ; fi
    if [[ $vscode -eq 1 ]] ; then boolvscode=TRUE ; else boolvscode=FALSE ; fi
    if [ "$arch" = "Darwin" ] ; then
        if [[ $xcode -eq 1 ]] ; then boolxcode=TRUE ; else boolxcode=FALSE ; fi
    fi
    if [[ $android -eq 1 ]] ; then boolAndroid=TRUE ; else boolAndroid=FALSE ; fi
    if [[ $only -eq 1 ]] ; then boolOnly=TRUE ; else boolOnly=FALSE ; fi
    # shellcheck disable=SC2046
    options=$(zenity --list --checklist --multiple --width=450 --height=300 \
        --title="$header" --window-icon=./installer.svg \
        --text="Select the options to install" \
        --column="Install" --column="Option" \
        "$boolconfig" "Configuration Changes" \
        "$boolfonts" "Fonts" \
        "$boolpackages" "Package Updates" \
        "$boolvscode" "VS Code Extensions" \
        ${boolxcode:+ $boolxcode "XCode Initialization"} \
        "$boolAndroid" "Enable Android Studio Configuration Changes" \
        "$boolOnly" "Only install selected")
    result=$?
    if [ $result -ne 0 ]
    then
        exit $result
    fi

    IFS='|' read -r -a optionArray <<< "$options"

    # reset flags
    config=0
    fonts=0
    packages=0
    vscode=0
    xcode=0
    only=0

    # parse flags from zenity
    for option in "${optionArray[@]}"
    do
        case $option in
            "Configuration Changes")
                config=1
                ;;
            "Fonts")
                fonts=1
                ;;
            "Package Updates")
                packages=1
                ;;
            "VS Code Extensions")
                vscode=1
                ;;
            "XCode Initialization")
                setXcode
                ;;
            "Enable Android Studio Configuration Changes")
                android=1
                ;;
            "Only install selected")
                only=1
                ;;
            *)
                help >&2
                exit 1
                ;;
        esac
    done
    if [[ $debug -eq 1 ]]
    then
        echo "Option settings: "
        echo -n "  config:  "
        echo $config
        echo -n "  fonts:   "
        echo $fonts
        echo -n "  packages:"
        echo $packages
        echo -n "  vs code: "
        echo $vscode
        echo -n "  xcode:   "
        echo $xcode
        echo -n "  android: "
        echo $android
        echo -n "  ONLY:    "
        echo $only
    fi
fi

if [[ $gui -eq 1 ]]
then
    coproc zenity --progress --pulsate --no-cancel --width=400 \
        --title="$header" --window-icon=./installer.svg
fi

g_header "$header"

if [[ $only -eq 0 ]]
then
    installBashd
    installBin
    installOSBin
    installVim
fi
if [[ $config -eq 1 ]]
then
    installConfig
fi
if [[ $vscode -eq 1 ]]
then
    source ./install_vscode_extensions.sh "$gui" "$debug"
fi
if [[ $fonts -eq 1 ]]
then
    source ./install_nonfree_fonts.sh "$gui" "$debug"
fi

# Process OS-specific files
[ -f "./install_${arch}.sh" ] && source "./install_${arch}.sh" "$packages" "$fonts" "$config" "$xcode" "$gui" "$yes" "$debug"
[ -f "./install_${arch}_${machinearch}.sh" ] && source "./install_${arch}_${machinearch}.sh" "$packages" "$fonts" "$config" "$xcode" "$gui" "$yes" "$debug"

if [[ $packages -eq 1 ]]
then
    source ./install_Python3.sh "$gui" "$yes" "$debug"
    source ./install_ruby_gems.sh "$gui" "$yes" "$debug"
fi

g_success "Done!"
if [[ $gui -eq 1 ]]
then
    eval "exec ${COPROC[1]}>&-" # close coproc input stream
fi
exit 0
