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
