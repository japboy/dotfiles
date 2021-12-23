#
# MAC OS X LOGIN SHELL CUSTOMISATION


##
# Built-in shell variables
# @see https://zsh.sourceforge.io/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell

# Set up `locale` properly
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Enable 256 colour terminal for Solarized theme
export TERM=xterm-256color

# Output format for `time` command
export TIMEFMT=$'\n========================\njob    : %J\ncpu       : %P\nuser      : %*Us\nsystem : %*Ss\ntotal  : %*Es\n========================\n'


##
# Environment variables

# Colourify `ls` output
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

# Disable to create `._` file in OS X
export COPYFILE_DISABLE=true

# Colourify `grep` output
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;37;41'

# Glob ignore pattern
export GLOBIGNORE=.:..


##
# Environment paths

# Private
export PATH="${HOME}/Developer/bin:${PATH}"
export MANPATH="${HOME}/Developer/share/man:${MANPATH}"

# MacPorts
#export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
#export MANPATH="/opt/local/share/man:${MANPATH}"

# Homebrew
export HOMEBREW_CELLAR="${HOME}/.homebrew/Cellar"
export HOMEBREW_PREFIX="${HOME}/.homebrew"
export PATH="${HOME}/.homebrew/sbin:${PATH}"
export PATH="${HOME}/.homebrew/bin:${PATH}"
export MANPATH="${HOME}/.homebrew/share/man:${MANPATH}"
export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PKG_CONFIG_PATH="${HOME}/.homebrew/lib/pkgconfig:${PKG_CONFIG_PATH}"
export LD_LIBRARY_PATH="${HOME}/.homebrew/lib"

# XDG Base Directory
export XDG_CONFIG_HOME=${HOME}/.config

# ccache
export PATH="$(brew --prefix ccache)/libexec:${PATH}"

# anyenv
export PATH="${HOME}/.anyenv/bin:${PATH}"

# Go (w/ anyenv)
#export PATH="${GOROOT}/bin:${PATH}"
#export PATH="${PATH}:${GOPATH}/bin"

# Mono
export MONO_GAC_PREFIX="$(brew --prefix)"

# Visual Studio Code (code)
export PATH="~/Applications/Visual Studio Code.app/Contents/Resources/app/bin:${PATH}"

# yarn
export PATH="${HOME}/.yarn/bin:${PATH}"


##
# Additional settings

# Prevent file lost by redirection
# Use `>|` instead of `>`
set -o noclobber


##
# Additional aliases

# Prevent file/directory lost
alias mv='mv -i'

if ! which trash &> /dev/null
then
    alias rm='rm -i'
else
    alias rm='trash'
    alias rmdir='trash'
fi

# OS X Wi-Fi utility
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'

# Copy my global IP to clipboard
alias myip='curl http://checkip.amazonaws.com/ | pbcopy'

# Use NeoVim as Vim
alias vim='nvim'


##
# Editor settings

# Set default text editor and also for Git
export EDITOR='nvim'

# Set alternate text editor
export ALTERNATE_EDITOR='code --wait'


##
# gisty
# https://github.com/swdyh/gisty

export GISTY_DIR="${HOME}/Dropbox/Workspace/com.github.gist"
export GISTY_SSL_VERIFY='NONE'


# Load extra settings
[ -f "${HOME}/.shell_extras" ] && source "${HOME}/.shell_extras"
