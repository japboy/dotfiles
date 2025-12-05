#
# MAC OS X RUNTIME SHELL CUSTOMISATION


##
# Zsh

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# @see https://formulae.brew.sh/formula/zsh-autosuggestions
[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
# @see https://formulae.brew.sh/formula/zsh-completions
if type brew &> /dev/null
then
    FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
    autoload -Uz compinit
    compinit
fi
# @see https://formulae.brew.sh/formula/zsh-syntax-highlighting
[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

##
# direnv
# @see https://direnv.net/

eval "$(direnv hook zsh)"

##
# mise
# @see https://mise.jdx.dev/installing-mise.html#zsh

eval "$(mise activate zsh)"

##
# Generic Colouriser
# @see https://github.com/garabik/grc#zsh

[ -f "$(brew --prefix)/etc/grc.zsh" ] && source "$(brew --prefix)/etc/grc.zsh"

##
# Git
# @see https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# @see https://formulae.brew.sh/formula/git-extras

if [ "${HOME}/.git-prompt.sh" ]
then
    source "${HOME}/.git-prompt.sh"
    GIT_PS1_SHOWCOLORHINTS=1
    precmd () { __git_ps1 "%n" ":%~$ " "|%s" }
fi
[ -f "$(brew --prefix git-extras)/share/git-extras/git-extras-completion.zsh" ] && source "$(brew --prefix git-extras)/share/git-extras/git-extras-completion.zsh"

##
# ngrok
# @see https://ngrok.com/docs/agent/cli#ngrok-completion

if command -v ngrok &> /dev/null
then
    eval "$(ngrok completion)"
fi
