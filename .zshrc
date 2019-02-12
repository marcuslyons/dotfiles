# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to oh-my-zsh installation.
export ZSH="/home/mlyons/.oh-my-zsh"
ZSH_THEME="nanotech"

# Plugins
plugins=(git colored-man colorize github jira vagrant virtualenv pip python zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# User configuration
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# aliases
# Use vim for editing config files
alias zshconfig="vim ~/.zshrc"
alias svim="sudo vim"

# Navigation
alias ..="cd .."
alias ...="cd ../.."

# Utility
alias remove="rm -rf "
alias locip='ifconfig | grep inet'
alias look='less -FX'

# Git
alias status="clear && git status"
alias push="git push"
alias pull="git pull"
alias add="git add "
alias all="git add --a"
alias commit="git commit -m "
alias checkout="git checkout"

# WSL Quirks
# Powershell
alias power="powershell.exe"

#Change ls colours
LS_COLORS="ow=01;36;40" && export LS_COLORS

##make cd use the ls colours
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
autoload -Uz compinit
compinit

# functions
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}
