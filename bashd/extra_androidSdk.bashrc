#!/usr/bin/env bash

##
# Android SDK specific scripting
#
# Call this script manually if machine is to be used for Android development
##

# Adjust this to point to the correct location for the local Android SDK installation
declare -a possibleSdks=(
    "${HOME}/Library/Android/sdk"
    "${HOME}/dev/android-sdk"
    "${HOME}/Android/Sdk"
)
for dir in "${possibleSdks[@]}"
do
    if [ -d "$dir" ]
    then
        ANDROID_HOME=$dir
    fi
done

if [ -d "${ANDROID_HOME}" ]
then
    PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
    # shellcheck disable=SC2012
    BUILD_TOOLS_VERSION=$(ls -1 "${ANDROID_HOME}/build-tools/" | sort | tail -n 1 | tr -d '\r\n')
    PATH=${PATH}:${ANDROID_HOME}/build-tools/${BUILD_TOOLS_VERSION}:${ANDROID_HOME}/cmdline-tools/latest
    export PATH
fi

alias avdmgr="avdmanager"
alias sdkmgr="sdkmanager"

adbd () {
    adb -s "$(get_device)" "$@"
}

get_device () {
    local -r devices=$(adb devices | grep device$)
    if [ "$(wc -l <<< "$devices")" -eq 1 ]
    then
        awk '{print $1}' <<< "$devices"
    else
        IFS=$'\n' devices=("$devices")
        unset IFS
        local device
        PS3="Select a device # "
        select device in "${devices[@]}"
        do
            if [ -n "$device" ]
            then
                awk '{print $1}' <<< "$device"
            fi
            break
        done
    fi
}

logcat () {
    local device
    device=$(get_device)
    if [ -z "$1" ]
    then
        adb -s "$device" logcat | coloredlogcat.py
    else
        local filters=""
        for f in "$@"
        do
            export filters="$filters $f:*"
        done
        echo "filters $filters"
        adb -s "$device" logcat "$filters" "*:S" | coloredlogcat.py
    fi
}
