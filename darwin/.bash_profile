#
# MAC OS X LOGIN SHELL CUSTOMISATION
#
# NOTE 1:
# Both of `.bash_profile` and `.profile` cannot be existed at once. The
# higher priority is given to `.bash_profile`, and it overrides all the
# setting of `.profile` if both of them exist.
#
# NOTE 2:
# There are some differences betweetn `.bash_profile` and `.bashrc`.
# The former is executed to configure your shell when you login. On the
# other hand, the latter is executed everytime you open a new terminal
# window.
#
# NOTE 3:
# To reload `.bash_profile` or `.bashrc`:
# source ~/.bash_profile


##
# Environment variables

# Set up `locale` properly
export LANG=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

# Glob ignore pattern
export GLOBIGNORE=.:..

# Enable 256 colour terminal for Solarized theme
export TERM=xterm-256color

# Colourify `ls` output
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

# Colourify `grep` output
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;37;41'

# Disable to create `._` file in OS X
export COPYFILE_DISABLE=true


##
# Environment paths

# Private
export PATH="${HOME}/Developer/bin:${PATH}"
export MANPATH="${HOME}/Developer/share/man:${MANPATH}"

# MacPorts
#export PATH="/opt/local/bin:/opt/local/sbin:${PATH}"
#export MANPATH="/opt/local/share/man:${MANPATH}"

# Homebrew
export PATH="${HOME}/.homebrew/sbin:${PATH}"
export PATH="${HOME}/.homebrew/bin:${PATH}"
export MANPATH="${HOME}/.homebrew/share/man:${MANPATH}"
export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PKG_CONFIG_PATH="${HOME}/.homebrew/lib/pkgconfig:${PKG_CONFIG_PATH}"

# XDG Base Directory
export XDG_CONFIG_HOME=${HOME}/.config

# ccache
export PATH="$(brew --prefix ccache)/libexec:${PATH}"

# GCC
export PATH="$(brew --prefix apple-gcc42)/bin:${PATH}"

# Fsharp
export MONO_GAC_PREFIX="$(brew --prefix)"

# anyenv
export PATH="${HOME}/.anyenv/bin:${PATH}"
eval "$(anyenv init -)"
[ -f "${HOME}/.anyenv/completions/anyenv.bash" ] && source "${HOME}/.anyenv/completions/anyenv.bash"

# pyenv anaconda hotfix
# http://qiita.com/y__sama/items/5b62d31cb7e6ed50f02c
#export PATH="${PYENV_ROOT}/versions/anaconda3-4.2.0/bin/:${PATH}"

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

if ! which rmtrash &> /dev/null
then
    alias rm='rm -i'
else
    alias rm='rmtrash'
    alias rmdir='rmtrash'
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
export ALTERNATE_EDITOR='code'


##
# Generic Colouriser
# `brew install grc` first!

[ -f "$(brew --prefix)/etc/grc.bashrc" ] && source "$(brew --prefix)/etc/grc.bashrc"


##
# Git shell optimisation
# `brew unlink git && brew link git` after upgrading

if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] \
    && [ -f "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh" ] \
    && [ -f "$(brew --prefix)/etc/bash_completion.d/git-extras" ]
then
    source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
    source "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh"
    source "$(brew --prefix)/etc/bash_completion.d/git-extras"
    PS1='\h:\W$(__git_ps1 " (%s)") \u\$ '
fi


##
# gibo
# https://github.com/simonwhitaker/gitignore-boilerplates
[ -f "$(brew --prefix)/etc/bash_completion.d/gibo-completion.bash" ] && source "$(brew --prefix)/etc/bash_completion.d/gibo-completion.bash"


##
# gisty
# https://github.com/swdyh/gisty

export GISTY_DIR="${HOME}/Dropbox/Workspace/com.github.gist"
export GISTY_SSL_VERIFY='NONE'


##
# Bash completions
# https://github.com/Homebrew/homebrew-completions

# Python Package Index completion
[ -f "$(brew --prefix)/etc/bash_completion.d/pip" ] && source "$(brew --prefix)/etc/bash_completion.d/pip"

# RubyGems completion
[ -f "$(brew --prefix)/etc/bash_completion.d/gem" ] && source "$(brew --prefix)/etc/bash_completion.d/gem"


# Load extra settings
[ -f "${HOME}/.bash_extras" ] && source "${HOME}/.bash_extras"
