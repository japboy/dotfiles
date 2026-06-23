#!/bin/bash

#
# BOOTSTRAP
#
# Install and update:
# bash <(curl -L https://raw.github.com/japboy/dotfiles/master/bootstrap.sh)
#
# Install and update without Git
# mkdir -p ~/.dotfiles
# curl -L https://github.com/japboy/dotfiles/archive/master.tar.gz | tar zxvf - -C ~/.dotfiles --strip-components=1
# bash ~/.dotfiles/bootstrap.sh sync


##
# Variables

OS=$(uname -a)
CWD=$(pwd)

TEXT_BOLD=$(tput bold)
TEXT_RED=$(tput setaf 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

DOTFILES_REPO='https://github.com/japboy/dotfiles.git'
DOTFILES_PATH="${HOME}/.dotfiles"

# Suffix used to keep backup file names collision-free across runs.
BACKUP_SUFFIX=$(date '+%Y%m%d%H%M%S')


##
# Functions

# Link every file under `<repo>/<target_parent>` into `${HOME}`, preserving
# the relative directory layout. Idempotent and deterministic: destinations are
# always absolute (independent of the current working directory), existing real
# files are backed up once, and symlinks we manage are refreshed in place.
function make_link {
    local target_parent="${1:-}"

    if [ -z "${target_parent}" ]
    then
        echo "${TEXT_RED}Link source path required. Aborted.${TEXT_RESET}"
        return 1
    fi

    # Resolve the symlink-free source root so generated links stay valid even if
    # `~/.dotfiles` is itself a symlink, and so idempotency checks are stable.
    local src_root
    src_root=$(cd "${DOTFILES_PATH}/${target_parent}" 2>/dev/null && pwd -P)

    if [ -z "${src_root}" ]
    then
        echo "${TEXT_RED}Source not found: ${DOTFILES_PATH}/${target_parent}. Aborted.${TEXT_RESET}"
        return 1
    fi

    local had_error=0

    # Enumerate files/symlinks with find's own predicates (no grep dependency)
    # and NUL-delimit so paths with spaces or newlines are handled safely.
    while IFS= read -r -d '' src_file
    do
        local rel="${src_file#${src_root}/}"
        local dst="${HOME}/${rel}"
        local dst_dir="${dst%/*}"

        if ! mkdir -p "${dst_dir}"
        then
            echo "${TEXT_RED}Failed to create directory: ${dst_dir}${TEXT_RESET}"
            had_error=1
            continue
        fi

        # If an ancestor directory is itself a symlink into the dotfiles tree
        # (e.g. `~/.agents` -> `<repo>/common/.agents`), ${dst} resolves back to
        # ${src_file}. Linking would back up and clobber the source itself, so
        # skip: the file is already reachable through that ancestor symlink.
        local dst_real
        dst_real="$(cd "${dst_dir}" 2>/dev/null && pwd -P)/${dst##*/}"
        [ "${dst_real}" = "${src_file}" ] && continue

        # Decide what to do with whatever currently occupies ${dst}.
        if [ -L "${dst}" ]
        then
            local current
            current=$(readlink "${dst}")

            # Already correct: nothing to do (idempotent no-op).
            [ "${current}" = "${src_file}" ] && continue

            case "${current}" in
                "${DOTFILES_PATH}"/*|"${src_root%/*}"/*)
                    # A stale link we manage (old layout/renamed file): refresh.
                    rm -f "${dst}"
                    ;;
                *)
                    # A symlink we did not create: never clobber it silently.
                    echo "${TEXT_RED}Skip (foreign symlink): ${dst} -> ${current}${TEXT_RESET}"
                    continue
                    ;;
            esac
        elif [ -e "${dst}" ]
        then
            # A real file/directory is in the way: back it up exactly once.
            local backup="${dst}.orig"
            [ -e "${backup}" ] && backup="${dst}.orig.${BACKUP_SUFFIX}"

            if ! mv "${dst}" "${backup}"
            then
                echo "${TEXT_RED}Failed to back up: ${dst}${TEXT_RESET}"
                had_error=1
                continue
            fi
            echo "Backed up: ${dst} -> ${backup}"
        fi

        if ln -s "${src_file}" "${dst}"
        then
            echo "Symlink created: ${dst}"
        else
            echo "${TEXT_RED}Failed to link: ${dst}${TEXT_RESET}"
            had_error=1
        fi
    done < <(find "${src_root}" \( -type f -o -type l \) \
        -not -name '.DS_Store' \
        -not -path '*/Services/*.workflow/*' \
        -print0)

    return ${had_error}
}


##
# Main process

echo "${TEXT_BOLD}Starting...${TEXT_RESET}"

# Skip fetching from Git if run with `sync` parameter
if [ "${1:-}" != 'sync' ]
then
    echo "${TEXT_BOLD}Fetching files from Git repository...${TEXT_RESET}"

    # Check if `git` command available or not
    if ! command -v git &> /dev/null
    then
        echo "${TEXT_RED}Git command not found. Aborted.${TEXT_RESET}"
        exit 1
    fi

    # Check if `~/.dotfiles` exists or not
    if [ ! -d "${DOTFILES_PATH}" ]
    then
        git clone --recursive "${DOTFILES_REPO}" "${DOTFILES_PATH}"
    elif [ -d "${DOTFILES_PATH}/.git" ]
    then
        if cd "${DOTFILES_PATH}"
        then
            git pull --ff origin master
            git submodule update --recursive
            cd "${CWD}" || exit 1
        else
            echo "${TEXT_RED}Failed to enter ${DOTFILES_PATH}. Aborted.${TEXT_RESET}"
            exit 1
        fi
    else
        echo "${TEXT_RED}Destination path already exists. Aborted.${TEXT_RESET}"
        exit 1
    fi
fi

# Setup macOS environment
if [[ ${OS} =~ Darwin ]]
then
    echo "${TEXT_BOLD}Installing for macOS...${TEXT_RESET}"

    # Run `bootstrap-darwin.sh`
    if ! zsh "${DOTFILES_PATH}/bootstrap-darwin.sh"
    then
        echo "${TEXT_RED}Error occurred. Aborted.${TEXT_RESET}"
        exit 1
    fi

    make_link 'darwin' || echo "${TEXT_RED}Some 'darwin' links failed.${TEXT_RESET}"
fi

# Setup WSL environment
if [[ "${OS}" =~ 'WSL' ]]
then
    echo "${TEXT_BOLD}Installing for WSL...${TEXT_RESET}"

    # Run `bootstrap-wsl.sh`
    if ! bash "${DOTFILES_PATH}/bootstrap-wsl.sh"
    then
        echo "${TEXT_RED}Error occurred. Aborted.${TEXT_RESET}"
        exit 1
    fi

    make_link 'linux' || echo "${TEXT_RED}Some 'linux' links failed.${TEXT_RESET}"
fi

# Setup common environment
echo "${TEXT_BOLD}Installing for common environment...${TEXT_RESET}"
make_link 'common' || echo "${TEXT_RED}Some 'common' links failed.${TEXT_RESET}"

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

echo 'Git settings update.'

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
    DOTFILES_PATH \
    BACKUP_SUFFIX

unset -f make_link
