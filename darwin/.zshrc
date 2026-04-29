#
# RUNTIME SHELL CUSTOMISATION

##
# Runtime settings

# Colourify `ls` output
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad

# Colourify `grep` output
export GREP_COLOR='1;37;41'
alias grep='grep --color=auto'

# Output format for `time` command
export TIMEFMT=$'\n========================\njob    : %J\ncpu       : %P\nuser      : %*Us\nsystem : %*Ss\ntotal  : %*Es\n========================\n'


##
# Aliases

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
# Zsh

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
# Prevent file lost by redirection
# Use `>|` instead of `>`
setopt NO_CLOBBER
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

if [ -f "${HOME}/.git-prompt.sh" ]
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


##
# Visual Studio Code (code)
export PATH="${HOME}/Applications/Visual Studio Code.app/Contents/Resources/app/bin:${PATH}"


# Load extra settings
[ -f "${HOME}/.shell_extras" ] && source "${HOME}/.shell_extras"
