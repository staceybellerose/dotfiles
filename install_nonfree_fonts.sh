#!/usr/bin/env bash
# shellcheck disable=SC1091

# Install fonts that I have purchased and stored on my Dropbox account.
# This will only work once Dropbox has been configured and linked to this system.

# THIS SCRIPT WILL ONLY WORK IF YOU HAVE A DROPBOX ACCOUNT AND HAVE jq INSTALLED!

source ./bin/utils.sh

gui="$1"
debug="$2"

arch=$(uname -s)

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

if [ "$arch" = "Darwin" ]
then
    FONTSDIR="${HOME}/Library/Fonts"
else
    FONTSDIR="$HOME/.fonts/FromDropbox"
fi

# Check to see if Dropbox has been configured for this user.
if [ -f "$HOME/.dropbox/info.json" ] && type -P jq &> /dev/null
then
    # Determine the base folder used by Dropbox (I don't like using ~/Dropbox).
    DROPBOXHOME=$(jq -r '.personal.path' "$HOME/.dropbox/info.json")
    # Check to see if the font folder exists locally.
    if [ -d "$DROPBOXHOME/Fonts" ]
    then
        mkdir -p "$FONTSDIR" && {
            e_bold "Installing Fonts"
            # Find all TTF and OTF files and copy them to the proper user folder.
            find "$DROPBOXHOME/Fonts" \( -iname "*.ttf" -o -iname "*.otf" \) -print0 | while IFS= read -r -d '' filename
            do
                file=$(basename "$filename")
                if [ ! -e "$FONTSDIR/$file" ]
                then
                    cp $CPOPT "$filename" "$FONTSDIR"
                    reportResult "Installed font $file" "Unable to install font $file"
                fi
            done
        }
    fi
fi
