#!/bin/bash

#
# BOOTSTRAP
#
# Install and update:
# bash <(curl -L https://raw.github.com/japboy/dotfiles/master/bootstrap.sh)
#
# Install and update without Git
# curl -L https://github.com/japboy/dotfiles/archive/master.tar.gz | tar zxvf - -C ~/.dotfiles
# bash ~/.dotfile/bootstrap.sh sync


##
# Variables

OS=$(uname -s)
CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_REPO='https://github.com/japboy/dotfiles.git'
DOTFILES_PATH="${HOME}/.dotfiles"


##
# Functions

# Update shell
function update {
    PROFILE_PATH="${HOME}/.bash_profile"
    RC_PATH="${HOME}/.bashrc"

    if [ -f ${PROFILE_PATH} ]
    then
        source ${PROFILE_PATH}
    fi

    if [ -f ${RC_PATH} ]
    then
        source ${RC_PATH}
    fi

    unset PROFILE_PATH RC_PATH
}

# Link dotfiles to home directory
function link {
    DIR=${1}

    if [ -z "${DIR}" ]
    then
        echo "${TEXT_RED}Link source path required. Aborted.${TEXT_RESET}"
        unset DIR
        exit 1
    fi

    for TARGET in ${DOTTARGETS_PATH}/${DIR}/.[^.]*
    do
        DEST="${HOME}/$(basename ${TARGET})"

        if [ -L ${DEST} ]
        then
            rm ${DEST}
            echo "Symlink removed ${DEST}"
            ln -s ${TARGET} ${DEST}
            echo "Symlink created ${DEST}"
        elif [ -f ${DEST} ]
        then
            mv ${DEST} ${DEST}.orig
            echo "File/Directory renamed to ${DEST}.orig"
            ln -s ${TARGET} ${DEST}
            echo "Symlink created ${DEST}"
        elif [ -d ${DEST} ]
        then
            for CHILD_TARGET in ${DEST}/.[^.]*
            do
                CHILD_DEST="${DEST}/$(basename ${CHILD_TARGET})"

                if [ -L ${CHILD_DEST} ]
                then
                    rm ${CHILD_DEST}
                    echo "Symlink removed ${CHILD_DEST}"
                    ln -s ${TARGET} ${CHILD_DEST}
                    echo "Symlink created ${CHILD_DEST}"
                elif [ -f ${CHILD_DEST} ]
                then
                    mv ${CHILD_DEST} ${CHILD_DEST}.orig
                    echo "File/Directory renamed to ${CHILD_DEST}.orig"
                    ln -s ${TARGET} ${CHILD_DEST}
                    echo "Symlink created ${CHILD_DEST}"
                fi

                unset CHILD_DEST
            done
            unset CHILD_TARGET
        fi

        unset DEST
    done

    update
    unset DIR TARGET
}


##
# Main process

echo "${TEXT_BOLD}Starting...${TEXT_RESET}"

# Skip fetching from Git if run with `sync` parameter
if [ -z "${1}" ] || [ 'sync' != ${1} ]
then
    echo "${TEXT_BOLD}Fetching files from Git repository...${TEXT_RESET}"

    # Check if `git` command available or not
    if ! which git &> /dev/null
    then
        echo "${TEXT_RED}Git command not found. Aborted.${TEXT_RESET}"
        exit 1
    fi

    # Check if `~/.dotfiles` exists or not
    if ! [ -d ${DOTFILES_PATH} ]
    then
        git clone --recursive ${DOTFILES_REPO} ${DOTFILES_PATH}
    elif [ -d ${DOTFILES_PATH}/.git ]
    then
        cd ${DOTFILES_PATH}
        git pull --ff origin master
        git submodule update --recursive
        cd ${CWD}
    else
        echo "${TEXT_RED}Destination path already exists. Aborted.${TEXT_RESET}"
        exit 1
    fi
fi

# Setup Mac OS X environment
if [ 'Darwin' == ${OS} ]
then
    echo "${TEXT_BOLD}Installing for Mac OS X...${TEXT_RESET}"

    # Run `bootstrap-darwin.sh`
    if ! bash ${DOTFILES_PATH}/bootstrap-darwin.sh
    then
        echo "${TEXT_RED}Error occurred. Aborted.${TEXT_RESET}"
        exit 1
    fi

    link 'darwin'
fi

# Setup Linux environment
if [ 'Linux' == ${OS} ]
then
    echo "${TEXT_BOLD}Installing for Linux...${TEXT_RESET}"
    link 'linux'
fi

# Setup common environment
echo "${TEXT_BOLD}Installing for common environment...${TEXT_RESET}"
link 'common'

# Initialise Git settings
if [ -z "$(git config --global user.name)" ]
then
    read -p "${TEXT_BOLD}Enter Git user.name:${TEXT_RESET} " GIT_CONFIG_USER_NAME
    git config --global user.name "${GIT_CONFIG_USER_NAME}"
    unset GIT_CONFIG_USER_NAME
fi

if ! echo $(git config --global user.email) | grep -q '^.*@.*\..*$'
then
    read -p "${TEXT_BOLD}Enter Git user.email:${TEXT_RESET} " GIT_CONFIG_USER_EMAIL
    git config --global user.email "${GIT_CONFIG_USER_EMAIL}"
    unset GIT_CONFIG_USER_EMAIL
fi

echo 'Git settings updated.'

# Finish
echo "${TEXT_BOLD}${TEXT_GREEN}All done.${TEXT_RESET}"

unset \
    OS \
    CWD \
    TEXT_BOLD \
    TEXT_RED \
    TEXT_GREEN \
    TEXT_RESET \
    DOTFILES_REPO \
    DOTFILES_PATH

unset -f \
    update \
    link
