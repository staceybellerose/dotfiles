#!/usr/bin/env bash

source ./bin/utils.sh

function installBashd() {
    e_bold "Installing bashd files"
    mkdir -p ${HOME}/.bashd
    cp -a bashd/* ${HOME}/.bashd && e_success "Installed bashd files" || e_error "Unable to install bashd files"
    echo "[ -f ~/.bashd/extra.bashrc ] && . ~/.bashd/extra.bashrc" >> ${HOME}/.bash_profile
}

function installVim() {
    e_bold "Installing vim files"
    mkdir -p ${HOME}/.vim
    cp -a vim/* ${HOME}/.vim && e_success "Installed vim files" || e_error "Unable to install vim files"
}

function installBin() {
    e_bold "Installing bin files"
    mkdir -p ${HOME}/bin
    cp -a bin/* ${HOME}/bin && e_success "Installed bin files" || e_error "Unable to install bin files"
}

function detectVSCode() {
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    elif [ -x "$(command -v codium)" ]; then
        code="$(command -v codium)"
    else
        return 1
    fi
    tmpfile=$$-vscode-extensions.log
    "$code" --list-extensions 2>&1 > ${TMPDIR}/${tmpfile}
    return 0
}

function installVSCodeExtension() {
    ext=$1
    grep -q $ext ${TMPDIR}/${tmpfile} &>/dev/null || {
        "$code" --install-extension $ext
    }
}

function installVSCodeCleanup() {
    rm ${TMPDIR}/${tmpfile}
}

function installAllVSCodeExtensions() {
    # Install Visual Studio Code/codium extensions
    detectVSCode && {
        e_bold "Installing ${C_FORE_BLUE}Visual Studio Code/codium Extensions"
        # General Extensions
        installVSCodeExtension ms-vsliveshare.vsliveshare # Live Share
        installVSCodeExtension CoenraadS.bracket-pair-colorizer-2 # Bracket Pair Colorizer 2
        installVSCodeExtension ybaumes.highlight-trailing-white-spaces # Highlight Trailing White Spaces
        installVSCodeExtension oderwat.indent-rainbow # Indent Rainbow
        installVSCodeExtension eriklynd.json-tools # JSON Tools
        installVSCodeExtension DotJoshJohnson.xml # XML Tools

        # Ruby / Rails extensions
        installVSCodeExtension rebornix.ruby # Ruby
        installVSCodeExtension wingrunr21.vscode-ruby # VSCode Ruby
        installVSCodeExtension castwide.solargraph # Ruby Solargraph
        installVSCodeExtension kaiwood.endwise # endwise
        installVSCodeExtension ninoseki.vscode-gem-lens # Gem Lens

        # React/JS Extensions
        installVSCodeExtension dbaeumer.vscode-eslint # ESLint
        installVSCodeExtension dsznajder.es7-react-js-snippets # ES7 Snippets
        installVSCodeExtension msjsdiag.debugger-for-chrome # Debugger for Chrome
        installVSCodeExtension firefox-devtools.vscode-firefox-debug # Debugger for Firefox

        # Other Language Extensions
        installVSCodeExtension vscjava.vscode-java-pack # Java Extension Pack
        installVSCodeExtension mathiasfrohlich.Kotlin # Kotlin Extension
        installVSCodeExtension ms-python.python # Python Extension
        installVSCodeExtension lizebang.bash-extension-pack # Bash Extension Pack

        # Misc Extensions
        installVSCodeExtension rafaelmaiolla.diff # diff syntax highlighting
        installVSCodeExtension fabiospampinato.vscode-diff # diff file comparator
        installVSCodeExtension EditorConfig.EditorConfig # EditorConfig support
        installVSCodeExtension yzhang.markdown-all-in-one # Markdown All in One
        installVSCodeExtension DavidAnson.vscode-markdownlint # Markdown Lint
        installVSCodeExtension dunstontc.viml # vim syntax highlighting

        # Themes
        installVSCodeExtension zhuangtongfa.material-theme # One Dark Pro
        installVSCodeExtension PKief.material-icon-theme # Material Icon Theme
    }
}

e_header "Dotfiles Installer"

installBin
installVim
installAllVSCodeExtensions

# Run OS-specific installer
arch=$(uname -s)
[ -f ./install_${arch}.sh ] && . ./install_${arch}.sh

e_success "Done!"
exit 0
