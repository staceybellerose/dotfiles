#!/usr/bin/env bash
# shellcheck disable=SC2034

C_BOLD=$(tput bold)
C_UNDERLINE=$(tput sgr 0 1)
C_RESET=$(tput sgr0)

C_BACK_BLACK=$(tput setab 0)
C_BACK_RED=$(tput setab 1)
C_BACK_GREEN=$(tput setab 2)
C_BACK_YELLOW=$(tput setab 3)
C_BACK_BLUE=$(tput setab 4)
C_BACK_MAGENTA=$(tput setab 5)
C_BACK_CYAN=$(tput setab 6)
C_BACK_WHITE=$(tput setab 7)

C_FORE_BLACK=$(tput setaf 0)
C_FORE_RED=$(tput setaf 1)
C_FORE_GREEN=$(tput setaf 2)
C_FORE_YELLOW=$(tput setaf 3)
C_FORE_BLUE=$(tput setaf 4)
C_FORE_MAGENTA=$(tput setaf 5)
C_FORE_CYAN=$(tput setaf 6)
C_FORE_WHITE=$(tput setaf 7)

gui=${gui:-0}

e_header() {
    printf "\n${C_BOLD}${C_FORE_MAGENTA}==========  %s  ==========${C_RESET}\n" "$@"
    true
}
e_arrow() {
    printf "➜ %s\n" "$@"
    true
}
e_success() {
    printf "${C_FORE_GREEN}✔ %s${C_RESET}\n" "$@"
    true
}
e_error() {
    printf "${C_FORE_RED}✖ %s${C_RESET}\n" "$@"
    true
}
e_warning() {
    printf "${C_FORE_YELLOW}➜ %s${C_RESET}\n" "$@"
    true
}
e_info() {
    printf "${C_FORE_BLUE}➜ %s${C_RESET}\n" "$@"
    true
}
e_underline() {
    printf "${C_UNDERLINE}${C_BOLD}%s${C_RESET}\n" "$@"
    true
}
e_bold() {
    printf "${C_BOLD}%s${C_RESET}\n" "$@"
    true
}
e_note() {
    printf "${C_UNDERLINE}${C_BOLD}${C_FORE_BLUE}Note:${C_RESET}  ${C_FORE_BLUE}%s${C_RESET}\n" "$@"
    true
}

# GUI wrapper functions

g_header() {
    if [[ $gui -eq 1 ]]
    then
        echo "# =" "$@" "=" >& "${COPROC[1]}"
    fi
    # always send the header to STDERR
    >&2 e_header "$@"
}
g_arrow() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" → "$@" >& "${COPROC[1]}"
    else
        e_arrow "$@"
    fi
}
g_success() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" ✓ "$@" >& "${COPROC[1]}"
    fi
    # always send the message to STDERR
    >&2 e_success "$@"
}
g_error() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" ✗ "$@" >& "${COPROC[1]}"
    fi
    # always send the error to STDERR
    >&2 e_error "$@"
}
g_warning() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" ! "$@" >& "${COPROC[1]}"
    fi
    # always send the warning to STDERR
    e_warning "$@"
}
g_info() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" → "$@" >& "${COPROC[1]}"
    fi
    # always send the message to STDERR
    >&2 e_info "$@"
}
g_underline() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" "$@" >& "${COPROC[1]}"
    else
        e_underline "$@"
    fi
}
g_bold() {
    if [[ $gui -eq 1 ]]
    then
        echo "#" "$@" >& "${COPROC[1]}"
    else
        e_bold "$@"
    fi
}
g_note() {
    if [[ $gui -eq 1 ]]
    then
        echo "# Note: " "$@" >& "${COPROC[1]}"
    else
        e_note "$@"
    fi
}

reportResult () {
    local result=$?
    if [[ $result -eq 0 ]]
    then
        g_success "$1"
    else
        g_error "$2"
    fi
}
