#
# COMMON PROCESS SHELL CUSTOMISATION

##
# Fundamental environment paths

typeset -U path PATH
path=(
    # Private
    "${HOME}/Developer/bin"
    "${HOME}/.local/bin"
    # Homebrew
    "${HOME}/.homebrew/sbin"
    "${HOME}/.homebrew/bin"

    "${path[@]}"
)
export PATH

export HOMEBREW_PREFIX="$(brew --prefix)"
export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"

typeset -U manpath MANPATH
manpath=(
    # Private
    "${HOME}/Developer/share/man"
    # Homebrew
    "${HOME}/.homebrew/share/man"

    "${manpath[@]}"
)
export MANPATH

typeset -U pkg_config_path PKG_CONFIG_PATH
pkg_config_path=(
    "${HOMEBREW_PREFIX}/lib/pkgconfig"
    "/usr/local/lib/pkgconfig"
    "/opt/X11/lib/pkgconfig"

    "${pkg_config_path[@]}"
)
export PKG_CONFIG_PATH

export LD_LIBRARY_PATH="${HOMEBREW_PREFIX}/lib"

typeset -U path PATH
path=(
    # ccache
    "$(brew --prefix ccache)/libexec"

    "${path[@]}"
)
export PATH


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

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"

typeset -U path PATH

# Bun
[ -d "${HOME}/.bun" ] && path=("${HOME}/.bun/bin" "${path[@]}")
# Git AI
# @see https://usegitai.com/
[ -d "${HOME}/.git-ai" ] && path=("${HOME}/.git-ai/bin" "${path[@]}")
# mise
# @see https://mise.jdx.dev/dev-tools/shims.html
[ -d "${HOME}/.local/share/mise" ] && path=("${HOME}/.local/share/mise/shims" "${path[@]}")
# pnpm
[ -d "${PNPM_HOME}" ] && path=("${HOME}/Library/pnpm" "${path[@]}")
# Yarn
[ -d "${HOME}/.yarn" ] && path=("${HOME}/.yarn/bin" "${path[@]}")

export PATH

# Mono
export MONO_GAC_PREFIX="${HOMEBREW_PREFIX}"

# Safe-chain
# @see https://github.com/AikidoSec/safe-chain
[ -d "${HOME}/.safe-chain" ] && source "${HOME}/.safe-chain/scripts/init-posix.sh"


##
# Editor settings

# Set default text editor and also for Git
export EDITOR='nvim'

# Set alternate text editor
export ALTERNATE_EDITOR='zed --wait'
