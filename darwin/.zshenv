#
# COMMON PROCESS SHELL CUSTOMISATION

##
# Fundamental environment paths

typeset -U path PATH

if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]
then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]
then
    source "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

path=(
    # Private
    "${HOME}/Developer/bin"
    "${HOME}/.local/bin"

    "${path[@]}"
)
export PATH

typeset -U manpath MANPATH
manpath=(
    # Private
    "${HOME}/Developer/share/man"

    "${manpath[@]}"
)
export MANPATH

typeset -U pkg_config_path PKG_CONFIG_PATH
pkg_config_path=(
    "${HOME}/.nix-profile/lib/pkgconfig"
    "${HOME}/.nix-profile/share/pkgconfig"
    "/usr/local/lib/pkgconfig"
    "/opt/X11/lib/pkgconfig"

    "${pkg_config_path[@]}"
)
export PKG_CONFIG_PATH


##
# Fundamental shell settings

# Disable to create `._` file in OS X
export COPYFILE_DISABLE=true

# Glob ignore pattern
export GLOBIGNORE=.:..

# Define base locales
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# XDG Base Directory
export XDG_CONFIG_HOME=${HOME}/.config


##
# Application settings

typeset -U path PATH

# Git AI
# @see https://usegitai.com/
[ -d "${HOME}/.git-ai" ] && path=("${HOME}/.git-ai/bin" "${path[@]}")

export PATH

# Safe-chain
# @see https://github.com/AikidoSec/safe-chain
[ -d "${HOME}/.safe-chain" ] && source "${HOME}/.safe-chain/scripts/init-posix.sh"


##
# Editor settings

# Set default text editor and also for Git
export EDITOR='nvim'

# Set alternate text editor
export ALTERNATE_EDITOR='zed --wait'
