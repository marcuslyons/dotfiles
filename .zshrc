# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to oh-my-zsh installation.
export ZSH="/Users/mlyons/.oh-my-zsh"

# Plugins
# at some point add this back in zsh-syntax-highlighting
plugins=(zsh-autosuggestions you-should-use)
source ~/.oh-my-zsh/oh-my-zsh.sh

# GPG Agent
# To fix the annoying gpg: signing failed: Inappropriate ioctl for device error
# https://github.com/keybase/keybase-issues/issues/2798
# export GPG_TTY=$(tty)

# if test -f ~/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
#   source ~/.gpg-agent-info
#   export GPG_AGENT_INFO
#   export SSH_AUTH_SOCK
#   export SSH_AGENT_PID
# else
#   eval $(gpg-agent --daemon --write-env-file ~/.gpg-agent-info)
# fi

# User configuration
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

#Change ls colours
LS_COLORS="ow=01;36;40" && export LS_COLORS

##make cd use the ls colours
# zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
# autoload -Uz compinit
# compinit

# aliases
# Use vim for editing config files
alias vz="vim ~/.zshrc"
alias cz="code ~/.zshrc"
alias sz="source ~/.zshrc"
alias svim="sudo vim"
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias deleteDSFiles="find . -name '.DS_Store' -type f -delete"

# Navigation
alias c="code ."
alias cc="clear"
alias ll="ls -la"
alias ..="cd ../"
alias ..l="cd ../ && ll"
alias ...="cd ../../"
alias ...l="cd ../../ && ll"
alias de="cd ~/Desktop"
alias d="cd ~/Dev"
alias hw="cd ~/github/healthwise"
alias ml="cd ~/github/marcuslyons"

# Utility
alias remove="rm -rf "
alias locip='ifconfig | grep inet'
alias look='less -FX'

# Docker / Compose
alias dcd='docker-compose down'
alias dcu='docker-compose up'
alias dcb='docker-compose up --build'

# Git
alias ga="git add ."
alias gd="git diff"
alias gf="git fetch"
alias gp="git pull"
alias gpr="gh pr create"
alias gs="clear && git status"
alias gpush="git push"
alias add="git add "
alias commit="git commit -m "
alias checkout="git checkout"

# remove all local branches except master
alias gbr="git branch | grep -v "master" | xargs git branch -D"

# npm aliases
alias ni="npm install"
alias nci="npm ci"
alias nrs="npm run start -s --"
alias nrb="npm run build -s --"
alias nrd="npm run dev -s --"
alias nrt="npm run test -s --"
alias nrtw="npm run test:watch -s --"
alias nrv="npm run validate -s --"
alias rmn="rm -rf node_modules"
alias flush-npm="rm -rf node_modules && npm i && say NPM is done"
alias nicache="npm install --prefer-offline"
alias nioff="npm install --offline"

## yarn aliases
alias yar="yarn run"
alias yas="yarn run start"
alias yab="yarn run build"
alias yat="yarn run test"
alias yav="yarn run validate"
alias yoff="yarn add --offline"
alias ypm="echo \"Installing deps without lockfile and ignoring engines\" && yarn install --no-lockfile --ignore-engines"

# functions
gi() { curl -L -s https://www.gitignore.io/api/$@; }
mg() { mkdir "$@" && cd "$@" || exit; }
cdl() { cd "$@" && ll; }
npm-latest() { npm info "$1" | grep latest; }
killport() { lsof -i tcp:"$*" | awk 'NR!=1 {print $2}' | xargs kill -9; }

# # NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"
