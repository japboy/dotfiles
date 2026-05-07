#
# LOGIN SHELL CUSTOMISATION

[ -f ${HOME}/.bashrc ] && source ${HOME}/.bashrc


##
# Fundamental environment paths

# Nix
[ -e ${HOME}/.nix-profile/etc/profile.d/nix.sh ] && source ${HOME}/.nix-profile/etc/profile.d/nix.sh

export PATH="${HOME}/Developer/bin:${HOME}/.local/bin:${PATH}"


##
# Fundamental shell settings

# History
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# Locale / XDG
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export XDG_CONFIG_HOME="${HOME}/.config"


##
# Editor settings

export EDITOR='nvim'
export ALTERNATE_EDITOR='zed'
