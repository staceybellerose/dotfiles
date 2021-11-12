#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

arch=$(uname -s)
machinearch=$(uname -m)

##
# Set up environment variables
##

if [ -d "$HOME/bin" ]
then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]
then
    PATH="$PATH:$HOME/.local/bin"
fi
export PATH
export LESS="-aeiR"
export MANPAGER="less -X"
export EDITOR=vi
export PAGER=less

# Load platform-specific paths

[ -f "$HOME/.bashd/path_$arch.bashrc" ] && source "$HOME/.bashd/path_$arch.bashrc"
[ -f "$HOME/.bashd/path_${arch}_${machinearch}.bashrc" ] && source "$HOME/.bashd/path_${arch}_${machinearch}.bashrc"

# define aliases
if command ls --color -d / &> /dev/null
then
    alias ls="command ls -Fa --color=auto" # GNU ls
    # load dircolors
    if [[ -r ~/.dircolors ]]
    then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
elif command ls -G -d / &> /dev/null
then
    alias ls="command ls -GFa" # BSD ls (and MacOS)
else
    alias ls="command ls -Fa" # Solaris ls
fi
alias ll="ls -lh"
alias dir="ls -lh"
alias ~="cd ~"
alias path='echo -e ${PATH//:/\\n}'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias du='du -h'
alias df='df -h'

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Increase Bash history size. Allow 32³ entries; the default is 500.
export HISTSIZE='32768'
export HISTFILESIZE="${HISTSIZE}"

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar
do
    shopt -s "$option" 2> /dev/null;
done;

# determine if we are within an X session
is_within_x () {
    if xhost >& /dev/null
        then true
        else false
    fi
}

# define colors for prompt command
C_DEFAULT="\[\e[m\]"
C_WHITE="\[\e[1m\]"
C_BLACK="\[\e[30m\]"
C_RED="\[\e[31m\]"
C_GREEN="\[\e[32m\]"
C_YELLOW="\[\e[33m\]"
C_BLUE="\[\e[34m\]"
C_PURPLE="\[\e[35m\]"
C_CYAN="\[\e[36m\]"
C_LIGHTGRAY="\[\e[37m\]"
C_DARKGRAY="\[\e[1;30m\]"
C_LIGHTRED="\[\e[1;31m\]"
C_LIGHTGREEN="\[\e[1;32m\]"
C_LIGHTYELLOW="\[\e[1;33m\]"
C_LIGHTBLUE="\[\e[1;34m\]"
C_LIGHTPURPLE="\[\e[1;35m\]"
C_LIGHTCYAN="\[\e[1;36m\]"
C_BG_BLACK="\[\e[40m\]"
C_BG_RED="\[\e[41m\]"
C_BG_GREEN="\[\e[42m\]"
C_BG_YELLOW="\[\e[43m\]"
C_BG_BLUE="\[\e[44m\]"
C_BG_PURPLE="\[\e[45m\]"
C_BG_CYAN="\[\e[46m\]"
C_BG_LIGHTGRAY="\[\e[47m\]"

# get current branch in git repo
parse_git_branch () {
    # Check if the current directory is in a Git repository.
    git rev-parse --is-inside-work-tree &>/dev/null || return;
    BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    DEFAULT_COLOR="\033[0m"
    GIT_PROMPT_COLOR="\033[37m"
    if [ ! "${BRANCH}" == "" ]
    then
        status=$(git status 2>&1 | tee)
        dirty=$(echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?")
        untracked=$(echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?")
        ahead=$(echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?")
        newfile=$(echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?")
        renamed=$(echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?")
        deleted=$(echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?")
        bits=''
        if [ "${renamed}" == "0" ]
        then
            bits=">${bits}"
            GIT_PROMPT_COLOR="\033[32m" # green
        fi
        if [ "${ahead}" == "0" ]
        then
            bits="*${bits}"
            GIT_PROMPT_COLOR="\033[34m" # blue
        fi
        if [ "${newfile}" == "0" ]
        then
            bits="+${bits}"
            GIT_PROMPT_COLOR="\033[32m" # green
        fi
        if [ "${untracked}" == "0" ]
        then
            bits="?${bits}"
            GIT_PROMPT_COLOR="\033[33m" # yellow
        fi
        if [ "${deleted}" == "0" ]
        then
            bits="x${bits}"
            GIT_PROMPT_COLOR="\033[31m" # red
        fi
        if [ "${dirty}" == "0" ]
        then
            bits="!${bits}"
            GIT_PROMPT_COLOR="\033[35m" # purple
        fi
        if [ ! "${bits}" == "" ]
        then
            bits=" ${bits}"
        fi
        echo -e "${GIT_PROMPT_COLOR}[${BRANCH}${bits}]$DEFAULT_COLOR "
    else
        echo ""
    fi
}

prompt_command () {
    EXIT=$?
    case "$TERM" in
        xterm-color|*-256color) color_prompt=yes;;
    esac
    local XTERM_TITLE=""
    if [[ $TERM == xterm* ]]
    then
        XTERM_TITLE="\[\e]0;\u@\H:\w\a\]"
    fi

    local BGJOBS_COLOR=${color_prompt:+$C_DARKGRAY}
    local BGJOBS=""
    if [ "$(jobs | head -c1)" ]
    then
        BGJOBS=" $BGJOBS_COLOR(bg:\j)"
    fi

    local DOLLAR_COLOR=${color_prompt:+$C_GREEN}
    if [[ ${EUID} == 0 ]]
    then
        DOLLAR_COLOR=${color_prompt:+$C_RED}
    fi
    local DOLLAR="$DOLLAR_COLOR\\\$"

    local USER_COLOR=${color_prompt:+$C_GREEN}
    if [[ ${EUID} == 0 ]]
    then
        USER_COLOR=${color_prompt:+$C_BG_RED$C_BLACK}
    fi

    local USER_STRING="\u@\h"
    if [[ ${arch} == Darwin ]]
    then
        USER_STRING="\u"
    fi

    local ARROW_COLOR=${color_prompt:+$C_GREEN}
    if [[ $EXIT != 0 ]]
    then
        ARROW_COLOR=${color_prompt:+$C_RED}
    fi
    arrow_character=$'\xe2\x86\x92'
    local ARROW="$ARROW_COLOR$arrow_character "

    local GIT="\`parse_git_branch\`"

    local HOMEPATH
    HOMEPATH=$(dirs +0)
    local SHORTPATH="\`echo \"$HOMEPATH\" | sed \"s:\([^/]\)[^/]*/:\1/:g\"\`"

    PS1="$XTERM_TITLE$ARROW$USER_COLOR$USER_STRING$C_GREEN\[\e[m\] $C_CYAN$SHORTPATH$C_DEFAULT $GIT\n$DOLLAR$BGJOBS \[\e[m\]"
}
export PROMPT_COMMAND=prompt_command

# taken from http://www.cyberciti.biz/faq/linux-unix-colored-man-pages-with-less-command/
man () {
    env \
    LESS_TERMCAP_mb="$(printf "\e[1;31m")" \
    LESS_TERMCAP_md="$(printf "\e[1;31m")" \
    LESS_TERMCAP_me="$(printf "\e[0m")" \
    LESS_TERMCAP_se="$(printf "\e[0m")" \
    LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
    LESS_TERMCAP_ue="$(printf "\e[0m")" \
    LESS_TERMCAP_us="$(printf "\e[1;32m")" \
    man "$@"
}

##
# clean up whiteboard photos (requires ImageMagick)
# taken from https://gist.github.com/lelandbatey/8677901
##
whiteboard () {
    convert "$1" -morphology Convolve DoG:15,100,0 -negate -normalize -blur 0x1 -channel RBG -level 60%,91%,0.1 "$2"
}

# taken from https://github.com/janmoesen/tilde/blob/master/.bash/commands
#
# Start your editor ($EDITOR, defaulting to "vim") on the last file specified.
# This is useful to quickly view the last in a series of timestamped files,
# e.g.:
#   $ ls -1 *.sql
#   20111021-112318.sql
#   20111021-112328.sql
#   20111021-112403.sql
#   20111021-112500.sql
#   20111021-112704.sql
#   20111021-112724.sql
#   20111021-112729.sql
#   20111021-113949.sql
#   $ vilast *.sql # will edit 20111021-113949.sql
vilast () {
    (($#)) && ${EDITOR:-vim} "${!#}"
}
# A quick way to invoke a read-only Vim on the last file. See "vilast".
viewlast () {
    (EDITOR=view vilast "$@")
}
# A quick way to show the last file in the Finder. See "vilast".
showlast () {
    (($#)) && show "${!#}"
}
# A quick way to "tail -f" the last file. See "vilast".
taillast () {
    (($#)) && tail -f "${!#}"
}
# A quick way to "cd" to the last directory. See "vilast".
cdlast () {
    for ((i = $#; i > 0; i--))
    do
        if [ -d "${!i}" ]
        then
            # shellcheck disable=SC2164
            cd "${!i}"
            return
        fi
    done
}

# make a dir and cd into it
mcd () {
    mkdir -p "$1"
    cd "$1" || return
}
# gets the user's default shell
getShell () {
    awk -F: '$1==u{print $7}' u="$(id -un)" /etc/passwd
}

# taken from https://github.com/janmoesen/tilde/blob/master/.bash/commands
# Show a one-line process tree of the given process, defaulting to the current
# shell. By specifying this as a function instead of a separate script, we
# avoid the extra shell process.
process-tree () {
    pid="${1:-$$}"
    orig_pid="$pid"
    local commands=()
    while [ "$pid" != "$ppid" ]
    do
        # Read the parent's process ID and the current process's command line.
        {
            read -rd ' ' ppid
            read -r command
        } < <(ps c -p "$pid" -o ppid= -o command= | sed 's/^ *//')
        # XXX This does not quite work yet with screen on OS x. Find out why.
        # echo "PID: $pid // PPID: $ppid // CMD: $command" 1>&2;
        # Stop when we have reached the first process, or an sshd/login process.
        if [ -z "$ppid" ] || [ "$ppid" -eq 0 ] || [ "$ppid" -eq 1 ] || [ "$command" = 'login' ] || [ "$command" = 'sshd' ]
        then
            # Include screen/xterm as the "root" process.
            if [ "$command" = 'screen' ] || [ "$command" = 'xterm' ]
            then
                commands=("$command" "${commands[@]}")
            fi
            break
        fi
        # Insert the command in the front of the process array.
        commands=("$command" "${commands[@]}")
        # Prepare for the next iteration.
        pid="$ppid"
        ppid=
    done
    # Hide the first bash process.
    set -- "${commands[@]}"
    if [ "$1" = '-bash' ] || [ "$1" = 'bash' ]
    then
        shift
        commands=("$@")
    fi
    # Print the tree with the specified separator.
    separator='→'
    output="$(IFS="$separator"; echo "${commands[*]}")"
    echo "${output//$separator/ $separator }"
}

# taken from https://github.com/janmoesen/tilde/blob/master/.bash/commands
# Show the uptime (including load) and the top 10 processes by CPU usage.
top10 () {
    uptime
    if [[ "$OSTYPE" =~ ^darwin ]]
    then
        ps waux -r
    else
        ps waux --sort='-%cpu'
    fi | head -n 11 | cut -c "1-${COLUMNS:-80}"
}

# Normalize `open` across Linux, macOS, and Windows.
if [ ! "$(uname -s)" = 'Darwin' ]
then
    if grep -q Microsoft /proc/version
    then
        # Ubuntu on Windows using the Linux subsystem
        alias open='explorer.exe'
    else
        alias open='xdg-open'
    fi
fi

##
# Load any platform-specific resources
##
[ -f "$HOME/.bashd/extra_$arch.bashrc" ] && source "$HOME/.bashd/extra_$arch.bashrc"
[ -f "$HOME/.bashd/extra_${arch}_${machinearch}.bashrc" ] && source "$HOME/.bashd/extra_${arch}_${machinearch}.bashrc"
[ -f "$HOME/.bashd/extra_x11.bashrc" ] && is_within_x && source "$HOME/.bashd/extra_x11.bashrc"
true
