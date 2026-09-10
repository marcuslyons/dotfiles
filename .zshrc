# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to oh-my-zsh installation.
# export ZSH="/Users/mlyons/.oh-my-zsh"

# # Plugins
# # at some point add this back in zsh-syntax-highlighting
# plugins=(zsh-autosuggestions you-should-use)
# source ~/.oh-my-zsh/oh-my-zsh.sh

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
alias ml="cd ~/github/marcuslyons"
alias in="cd ~/github/insider"
alias gr="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/grimoire"

# Utility
alias remove="rm -rf "
alias locip='ifconfig | grep inet'
alias look='less -FX'
alias bu="brew update && brew upgrade && brew cleanup"

# Docker / Compose
alias dcd='docker-compose down'
alias dcu='docker-compose up'
alias dcb='docker-compose up --build'

# Git
alias ga="git add"
alias gaa="git add ."
alias gap="git add --patch"
alias gd="git diff"
alias gds="git diff --staged"
alias gf="git fetch"
alias gp="git pull"
alias gu="git push"
alias gb="git branch"
alias gpr="gh pr create"
alias gs="git status"
alias gc="git commit"
alias gcb="git checkout -b"
alias gcm="git checkout main"
alias gcma="git checkout master"
alias gcl="git clone"

alias gl="git log --all --graph --pretty=\
	format: '%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
# workftrees
alias gwl="git worktree list"
alias gwr="git worktree remove "

# remove all local branches except main
alias gbr="git branch | grep -v "main" | xargs git branch -D"

# remove all local branches except master
alias gbrm="git branch | grep -v "master" | xargs git branch -D"

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

# pnpm aliases
alias pni="npm install"
alias pnci="npm ci"
alias pnrs="npm run start -s --"
alias pnrb="npm run build -s --"
alias pnrd="npm run dev -s --"
alias pnrt="npm run test -s --"
alias pnrtw="npm run test:watch -s --"
alias pnrv="npm run validate -s --"

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
TEAM_NAME=engagement

function unset_aws() {
    unset AWS_PROFILE
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_ACCESS_KEY_ID
    unset AWS_SESSION_TOKEN
}

function promote_role() {
    unset_aws
    if [ -z ${1} ]; then
        echo -e "ERROR: environment name needed"
    else
        if [[ "${1}" == "sbx" ]]; then
            AWSACCNO=206229966755
        elif [[ "${1}" == "dev" ]]; then
            AWSACCNO=781249922241
        elif [[ "${1}" == "prd" ]]; then
            AWSACCNO=781406854653
        else
            echo "Unknown environment"
            exit 1
        fi
        for i in $(aws sts assume-role --role-arn "arn:aws:iam::${AWSACCNO}:role/${1}-${TEAM_NAME}-privileged-role" --role-session-name "${1}" --duration-seconds 3600 | jq -r '.Credentials | "AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nAWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\nAWS_SESSION_TOKEN=\(.SessionToken)\n"'); do
            export "${i}"
        done
    fi
}
## Volta and Starship

eval "$(starship init zsh)"
export PATH="/usr/local/sbin:$PATH"
export PATH=/opt/homebrew/bin:/usr/local/sbin:/Users/marcuslyons/bin:/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
eval "$(pyenv init --path)"


export PATH="/opt/homebrew/opt/mongodb-community@5.0/bin:$PATH"
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

source ~/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script

# Added by Antigravity
export PATH="/Users/marcuslyons/.antigravity/antigravity/bin:$PATH"
# pi update alias (uses volta, avoids npm global shadow)
pi-update() {
  echo "Updating pi-coding-agent..."
  volta install @mariozechner/pi-coding-agent@latest
  echo "Updating pi-boomerang..."
  npm install -g pi-boomerang@latest
  echo "Running pi package updates..."
  pi update
  echo "Done. pi $(pi --version)"
}

# Added for oh-my-pi
export PATH="/Users/marcuslyons/.bun/bin:$PATH"
. "$HOME/.cargo/env"

export JIRA_USER_EMAIL="mlyons@insider.com"
export JIRA_API_TOKEN="ATATT3xFfGF0dLMK0He-ZW6iv4VCuNYkdB7pNy4gXgoHGrMZyqHGdrU7XrCOiyyoTIidGhLjFj8GydJf-1HVs9kNgSDUKihvzz75-3iCGcs0JNwussUvt3Hgr0a752nfAsEr3ntprLwAN9IE_JVW_5R8ubZ95iAq4LEJNFcF6tPOdUs0h3fTBI8=6B1024CA"
