#
# RUNTIME SHELL CUSTOMISATION

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


##
# Bash Line Editor
# @see https://github.com/akinomyoga/ble.sh

if command -v blesh-share &> /dev/null
then
    source "$(blesh-share)/ble.sh" --noattach
fi


##
# Runtime settings

# Shell options
shopt -s histappend
shopt -s checkwinsize

# Lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Chroot
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]
then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Colours
[ -x /usr/bin/dircolors ] && [ -f ${HOME}/.dir_colors/dircolors.256dark ] && eval $(dircolors ${HOME}/.dir_colors/dircolors.256dark)

# Default Prompt (will be overridden by Git section if available)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Completion
if ! shopt -oq posix
then
    [ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion
    [ -f /etc/bash_completion ] && source /etc/bash_completion
fi


##
# Aliases

[ -f ${HOME}/.bash_aliases ] && source ${HOME}/.bash_aliases

alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

alias mv='mv -i'
alias rm='rm -i'
alias vim='nvim'


##
# Git
# @see https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh

if [ -f ${HOME}/.git-prompt.sh ]
then
    source ${HOME}/.git-prompt.sh
    PS1='\h:\W$(__git_ps1 " (%s)") \u\$ '
fi


##
# direnv
# @see https://direnv.net/

command -v direnv &> /dev/null && eval "$(direnv hook bash)"


# Load extra settings
[ -f ${HOME}/.bash_extras ] && source ${HOME}/.bash_extras


# Attach ble.sh
if [ "${BLE_VERSION-}" ]
then
    ble-attach
fi
