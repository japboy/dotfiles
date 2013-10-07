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

# GCC
export PATH="$(brew --prefix)/Cellar/gcc48/4.8.1/bin:${PATH}"

# phpenv
# PATH should be overriden by rbenv
export PATH="${HOME}/.phpenv/bin:${PATH}"
eval "$(phpenv init -)"

# pyenv
export PATH="${HOME}/.pyenv/bin:${PATH}"
eval "$(pyenv init -)"

# rbenv
export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init -)"

# nenv
export PATH="${HOME}/.nenv/bin:${PATH}"
eval "$(nenv init -)"


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

# Set Sublime Text 2 alias
#alias subl="${HOME}/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"

# OS X Wi-Fi utility
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'


##
# Editor settings

# Set default text editor and also for Git
export EDITOR='vim'

# Set alternate text editor
#export ALTERNATE_EDITOR='subl -w'


##
# Generic Colouriser
# `brew install grc` first!

if [ -f "$(brew --prefix)/etc/grc.bashrc" ]
then
    source "$(brew --prefix)/etc/grc.bashrc"
fi


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
# gibo completion
# https://github.com/simonwhitaker/gitignore-boilerplates

if [ -f "$(brew --prefix)/etc/bash_completion.d/gibo-completion.bash" ]
then
    source "$(brew --prefix)/etc/bash_completion.d/gibo-completion.bash"
fi


##
# gisty
# https://github.com/swdyh/gisty

export GISTY_DIR="${HOME}/Dropbox/Workspace/com.github.gist"
export GISTY_SSL_VERIFY='NONE'


##
# Settings for Amazon EC2 API Tools
# http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html#set-aws-credentials

export JAVA_HOME="$(/usr/libexec/java_home)"
export EC2_HOME="${HOME}/Developer/opt/ec2-api-tools-1.6.5.3"
export EC2_URL='https://ec2.ap-northeast-1.amazonaws.com'
export PATH="${PATH}:${EC2_HOME}/bin"


# Load credential settings
if [ -f "${HOME}/.bash_extras" ]
then
    source "${HOME}/.bash_extras"
fi
