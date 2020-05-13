#!/bin/bash

source ./src/utils.sh

toInstall=()
toInstallCask=()

function promptToInstall() {
    test_result=$?
    name=$1; url=$2; useCask=$3
    shift 3
    app=("$@")
    [[ $test_result -eq 0 ]] && e_success "$name is already installed" || {
        e_warning "$name is not installed"
        install="h"
        while [ "$install" == "h" ]; do
            read -p "Do you want to install ${C_FORE_BLUE}$name${C_RESET}? [y/${C_BOLD}n${C_RESET}/h]: " install
            if [ "$install" == "y" ]; then
                if [ "$useCask" == "1" ]; then
                    toInstallCask+=( ${app[@]} )
                else
                    toinstall+=( ${app[@]} )
                fi
            elif [ "$install" == "h" ]; then
                open "$url"
            fi
        done
    }
}

function checkInstall() {
	app=$1; name=$2; url=$3
	type -P $app &> /dev/null
    promptToInstall "$name" "$url" "0" "$app"
}

function checkSubCommand() {
    app=$1; subcommand=$2; name=$3; url=$4
    command -v $subcommand &> /dev/null
    promptToInstall "$name" "$url" "0" "$app"
}

function checkCask() {
    cask=$1; name=$2; app=$3; url=$4
    test -d "/Applications/$app"
    promptToInstall "$name" "$url" "1" "$cask"
}

function checkJava() {
    name=$1; version=$2; url=$3
    cask=("oracle-jdk" "oracle-jdk-javadoc")
    /usr/libexec/java_home -v $version &> /dev/null
    promptToInstall "$name" "$url" "1" "${cask[@]}"
}

function checkNvm() {
    app=$1; name=$2; url=$3
    test -d "$HOME/.nvm"
    promptToInstall "$name" "$url" "0" "$app"
}

e_header "Mac Application Installer"

# Command Line Tools
checkInstall brew "Homebrew" "https://brew.sh/"
checkInstall rvm "Ruby Version Manager (rvm)" "https://rvm.io/"

# Homebrew Bottles
checkSubCommand coreutils gecho "Core Utilities" "https://www.gnu.org/software/coreutils"
checkSubCommand moreutils sponge "MoreUtils" "https://joeyh.name/code/moreutils/"
checkSubCommand findutils gfind "FindUtils" "https://www.gnu.org/software/findutils/"
checkSubCommand gnu-sed gsed "GNU sed" "https://www.gnu.org/software/sed/"
checkSubCommand grep ggrep "grep" "https://www.gnu.org/software/grep/"
checkSubCommand openssh scp "OpenSSH" "https://www.openssh.com/"
checkNvm nvm "nvm" "https://github.com/nvm-sh/nvm"
checkInstall automake "AutoMake" "https://www.gnu.org/software/automake/"
checkInstall autoconf "AutoConf" "https://www.gnu.org/software/autoconf"
checkInstall gnupg "GNU Pretty Good Privacy" "https://gnupg.org/"
checkInstall git "Git" "https://git-scm.com/"
checkInstall wget "Wget" "https://www.gnu.org/software/wget/"
checkInstall node "Node.js" "https://nodejs.org/en/"
checkInstall mysql "MySQL" "https://www.mysql.com/"
checkInstall sqlite3 "SQLite" "https://www.sqlite.org/"
checkInstall magick "ImageMagick" "https://imagemagick.org/"

# Homebrew Casks
checkCask android-studio "Android Studio" "Android Studio.app" "https://developer.android.com/studio"
checkCask atom "Atom" "Atom.app" "https://atom.io/"
checkCask balenaetcher "balena Etcher" "balenaEtcher.app" "https://www.balena.io/etcher/"
checkCask cpuinfo "CPU Info" "cpuinfo.app" "https://github.com/yusukeshibata/cpuinfo/"
checkCask db-browser-for-sqlite "DB Browser for SQLite" "DB Browser for SQLite.app" "https://sqlitebrowser.org/"
checkCask diffmerge "DiffMerge" "DiffMerge.app" "https://sourcegear.com/diffmerge/"
checkCask docker "Docker" "Docker.app" "https://www.docker.com/products/docker-desktop"
checkCask firefox "Firefox" "Firefox.app" "https://www.mozilla.org/en-US/exp/firefox/"
checkCask gimp "Gimp" "GIMP-2.10.app" "https://www.gimp.org/"
checkCask google-chrome "Google Chrome" "Google Chrome.app" "https://www.google.com/chrome/"
checkCask fork "Git-Fork" "Fork.app" "https://git-fork.com/"
checkCask inkscape "Inkscape" "Inkscape.app" "https://inkscape.org/"
checkCask iterm2 "iTerm2" "iTerm.app" "https://www.iterm2.com/"
checkCask macdown "MacDown" "MacDown.app" "https://macdown.uranusjr.com/"
checkCask macvim "MacVim" "MacVim.app" "https://github.com/macvim-dev/macvim"
checkCask openinterminal-lite "OpenInTerminal Lite" "OpenInTerminal-Lite.app" "https://github.com/Ji4n1ng/OpenInTerminal"
checkCask openineditor-lite "OpenInEditor Lite" "OpenInEditor-Lite.app" "https://github.com/Ji4n1ng/OpenInTerminal"
checkCask postman "Postman" "Postman.app" "https://www.postman.com/"
checkCask powrshell "PowerShell Core" "PowerShell.app" "https://microsoft.com/PowerShell"
checkCask projectlibre "Project Libre" "ProjectLibre.app" "https://www.projectlibre.com/"
checkCask pycharm-ce "PyCharm Community Edition" "PyCharm CE.app" "https://www.jetbrains.com/pycharm/"
checkCask scribus "Scribus" "Scribus.app" "https://www.scribus.net/"
checkCask thunderbird "Mozilla Thunderbird" "Thunderbird.app" "https://www.thunderbird.net/en-US/"
checkCask visual-studio-code "Visual Studio Code" "Visual Studio Code.app" "https://code.visualstudio.com/"
checkCask zoomus "Zoom.us" "zoom.us.app" "https://www.zoom.us/"

checkJava "Oracle JDK" "1.8" "https://www.oracle.com/technetwork/java/javase/overview/index.html"

echo "Those software will be installed: ${toinstall[@]} ${toInstallCask[@]}";
read -p "Let's do it now? [y/${C_BOLD}n${C_RESET}]: " install
if [ "$install" != "y" ]; then
    e_bold "Install cancelled."
	exit 1
fi

# Install the Command Line Tools and the Homebrew Bottles
for i in "${toinstall[@]}"
do
	e_bold "Installing ${C_FORE_BLUE}$i"
	if [ "$i" == "brew" ]; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
		brew doctor
        brew update
        brew upgrade
    elif [ "$i" == "rvm" ]; then
        curl -sSL https://get.rvm.io | bash -s stable --ruby --rails
        gem install bundler -v '=1.17.3'
        rvm docs generate-ri
    elif [ "$i" == "nvm" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
    else
        brew install $i
	fi
done

# Install the Homebrew Casks
for i in "${toInstallCask[@]}"
do
	e_bold "Installing ${C_FORE_BLUE}$i"
    brew cask install $i
done

# Add NPM Packages
e_bold "Configuring ${C_FORE_BLUE}npm"
npm install http-server

# Configure OpenInTerminal and OpenInEditor
if [ -d "/Applications/OpenInEditor-Lite.app" ]; then
    e_bold "Configuring ${C_FORE_BLUE}OpenInEditor Lite"
    if [ -d "/Applications/MacVim.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier MacVim
    elif [ -d "/Applications/Visual Studio Code.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier VSCode
    elif [ -d "/Applications/CotEditor.app" ]; then
        defaults write wang.jianing.app.OpenInEditor-Lite OIT_EditorBundleIdentifier CotEditor
    fi
fi
if [ -d "/Applications/OpenInTerminal-Lite.app" ]; then
    e_bold "Configuring ${C_FORE_BLUE}OpenInTerminal Lite"
    if [ -d "/Applications/iTerm.app" ]; then
        defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier iTerm
        defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false
    else
        defaults write wang.jianing.app.OpenInTerminal-Lite OIT_TerminalBundleIdentifier Terminal
    fi
fi

# Configure Mac Appearance
e_bold "Configuring ${C_FORE_BLUE}Mac Appearance"
osascript -e 'tell application "System Preferences" to quit'
osascript << EOF
tell application "System Preferences"
    reveal anchor "Main" of pane id "com.apple.preference.general"
    activate
end tell
EOF

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Show hidden files in Finder
defaults write com.apple.Finder AppleShowAllFiles -bool true
killall Finder

if [ -d "/Applications/iTerm.app" ]; then
    e_bold "Configuring ${C_FORE_BLUE}iTerm2"
    /bin/bash -c "$(curl -fsSL https://iterm2.com/shell_integration/install_shell_integration.sh)"
    open one-dark.itermcolors
fi

# Open instruction pages for manual post-install work
if [ -d "/Applications/OpenInTerminal-Lite.app" -o -d "/Applications/OpenInEditor-Lite.app" ]; then
    open "https://github.com/Ji4n1ng/OpenInTerminal/blob/master/Resources/README-Lite.md"
fi

exit 0
