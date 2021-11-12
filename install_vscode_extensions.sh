#!/usr/bin/env bash

source ./bin/utils.sh

# shellcheck disable=SC2034
gui="$1"
debug="$2"

TMPDIR=${TMPDIR:-/tmp}

(( installed=0 ))

detectVSCode () {
    if [ -d "/Applications/Visual Studio Code.app" ]
    then
        code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    elif [ -x "$(command -v code)" ]
    then
        code="$(command -v code)"
    elif [ -x "$(command -v codium)" ]
    then
        code="$(command -v codium)"
    else
        g_error "Unable to detect VS Code"
        return 1
    fi
    tmpfile=$$-vscode-extensions.log
    "$code" --list-extensions > "${TMPDIR}/${tmpfile}" 2>&1
    return 0
}

installVSCodeExtension () {
    ext=$1
    if grep -q "$ext" "${TMPDIR}/${tmpfile}" &>/dev/null
    then
        [[ $debug -eq 1 ]] && g_success "$ext is already installed"
    else
        g_arrow "Installing $ext"
        "$code" --install-extension "$ext" > /dev/null
        (( installed++ ))
    fi
}

installVSCodeCleanup () {
    rm "${TMPDIR}/${tmpfile}"
}

installAllVSCodeExtensions () {
    # Install Visual Studio Code/codium extensions
    detectVSCode && {
        g_bold "Installing VS Code/codium Extensions"
        # General Extensions
        installVSCodeExtension ms-vsliveshare.vsliveshare # Live Share
        installVSCodeExtension CoenraadS.bracket-pair-colorizer-2 # Bracket Pair Colorizer 2
        installVSCodeExtension ybaumes.highlight-trailing-white-spaces # Highlight Trailing White Spaces
        installVSCodeExtension oderwat.indent-rainbow # Indent Rainbow
        installVSCodeExtension eriklynd.json-tools # JSON Tools
        installVSCodeExtension DotJoshJohnson.xml # XML Tools
        installVSCodeExtension redhat.vscode-yaml # YAML
        # installVSCodeExtension eamodio.gitlens # Git Lens
        installVSCodeExtension ms-azuretools.vscode-docker # Docker
        installVSCodeExtension aaron-bond.better-comments # Better Comments
        installVSCodeExtension wmaurer.change-case # Change Case
        installVSCodeExtension Tyriar.sort-lines # Sort Lines
        installVSCodeExtension dakara.transformer # Text Transformer
        installVSCodeExtension fnando.linter # Linter
        installVSCodeExtension jerrygoyal.shortcut-menu-bar # Shortcut Menu Bar

        # Ruby / Rails extensions
        installVSCodeExtension rebornix.ruby # Ruby
        installVSCodeExtension wingrunr21.vscode-ruby # VSCode Ruby
        installVSCodeExtension castwide.solargraph # Ruby Solargraph
        installVSCodeExtension kaiwood.endwise # endwise
        installVSCodeExtension ninoseki.vscode-gem-lens # Gem Lens
        installVSCodeExtension karunamurti.haml # HAML

        # React/JS Extensions
        installVSCodeExtension dbaeumer.vscode-eslint # ESLint
        installVSCodeExtension dsznajder.es7-react-js-snippets # ES7 Snippets
        installVSCodeExtension msjsdiag.debugger-for-chrome # Debugger for Chrome
        installVSCodeExtension firefox-devtools.vscode-firefox-debug # Debugger for Firefox

        # Java Extensions
        installVSCodeExtension vscjava.vscode-java-pack # Java Extension Pack
        installVSCodeExtension redhat.java # Language Support for Java
        installVSCodeExtension vscjava.vscode-maven # Maven for Java
        installVSCodeExtension vscjava.vscode-java-debug # Debugger for Java
        installVSCodeExtension vscjava.vscode-java-dependency # Dependency Viewer for Java
        installVSCodeExtension vscjava.vscode-java-test # Java Test Runner
        installVSCodeExtension VisualStudioExptTeam.vscodeintellicode # Visual Studio Intellicode

        # Bash Extensions
        installVSCodeExtension lizebang.bash-extension-pack # Bash Extension Pack
        installVSCodeExtension foxundermoon.shell-format # Shell format
        installVSCodeExtension Remisa.shellman # Shell snippets
        installVSCodeExtension timonwong.shellcheck # Shellcheck for VS Code
        installVSCodeExtension mads-hartmann.bash-ide-vscode # IDE for Bash
        installVSCodeExtension rogalmic.bash-debug # Bash Debugger
        installVSCodeExtension rpinski.shebang-snippets # Shebang Snippets
        installVSCodeExtension ms-vscode.powershell # Powershell

        # Kotlin Extensions
        installVSCodeExtension sethjones.kotlin-on-vscode # Kotlin Extension Pack
        installVSCodeExtension mathiasfrohlich.Kotlin # Kotlin Extension
        installVSCodeExtension fwcd.kotlin # Kotlin IDE
        installVSCodeExtension formulahendry.code-runner # Code Runner
        installVSCodeExtension vscjava.vscode-gradle # Gradle Tasks
        installVSCodeExtension naco-siren.gradle-language # Gradle Language Support
        installVSCodeExtension esafirm.kotlin-formatter # Kotlin Formatter using ktlint

        # Python Extensions
        installVSCodeExtension ms-python.python # Python Extension
        installVSCodeExtension ms-python.vscode-pylance # Pylance Extension

        # Database Extensions
        installVSCodeExtension alexcvzz.vscode-sqlite # SQLite Databases
        installVSCodeExtension adpyke.vscode-sql-formatter # SQL Formatter
        installVSCodeExtension bajdzis.vscode-database # mysql, postgres database support
        installVSCodeExtension mtxr.sqltools # Database management tools

        # Misc Extensions
        installVSCodeExtension rafaelmaiolla.diff # diff syntax highlighting
        installVSCodeExtension fabiospampinato.vscode-diff # diff file comparator
        installVSCodeExtension EditorConfig.EditorConfig # EditorConfig support
        installVSCodeExtension yzhang.markdown-all-in-one # Markdown All in One
        installVSCodeExtension DavidAnson.vscode-markdownlint # Markdown Lint
        installVSCodeExtension dunstontc.viml # vim syntax highlighting
        installVSCodeExtension ionutvmi.path-autocomplete # Path Autocomplete
        installVSCodeExtension mikestead.dotenv # DotENV
        installVSCodeExtension ms-toolsai.jupyter # Jupyter Notebook support
        installVSCodeExtension wayou.vscode-todo-highlight # TO DO highlight
        installVSCodeExtension Gruntfuggly.todo-tree # TO DO tree in explorer pane
        installVSCodeExtension ExodiusStudios.comment-anchors # Comment anchors
        installVSCodeExtension jerrygoyal.shortcut-menu-bar # Add buttons to editor menu bar (since no toolbar)

        # Themes
        installVSCodeExtension zhuangtongfa.material-theme # One Dark Pro
        installVSCodeExtension vscode-icons-team.vscode-icons # VS Code Icon Theme
        installVSCodeExtension PKief.material-icon-theme # Material Icon Theme

        # Clean up temp file
        installVSCodeCleanup
        if ((installed > 0)); then
            g_success "$installed extensions installed"
        else
            g_info "No extensions to install"
        fi
    }
}

g_header "VSCode Extension Installer"
installAllVSCodeExtensions
