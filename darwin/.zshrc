#
# MAC OS X RUNTIME SHELL CUSTOMISATION


##
# Additional completion definitions for Zsh
# @see https://formulae.brew.sh/formula/zsh-completions
# @see https://github.com/zsh-users/zsh-completions

if type brew &> /dev/null
then
    FPATH=$(brew --prefix)/share/zsh-completions:${FPATH}
    autoload -Uz compinit
    compinit
fi

##
# All in one for **env
# @see https://github.com/anyenv/anyenv

eval "$(anyenv init -)"
[ -f "${HOME}/.anyenv/completions/anyenv.zsh" ] && source "${HOME}/.anyenv/completions/anyenv.zsh"

##
# Generic Colouriser
# @see https://github.com/garabik/grc#zsh

[ -f "$(brew --prefix)/etc/grc.zsh" ] && source "$(brew --prefix)/etc/grc.zsh"

##
# Git
# @see https://git-scm.com/book/en/v2/Appendix-A%3A-Git-in-Other-Environments-Git-in-Zsh

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%b'
