#!/bin/sh

install_brew() {
  # install homebrew if it's missing
  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # install from Brewfile if present
  if [ -f "$HOME/Brewfile" ]; then
    echo "Installing from Brewfile..."
    brew bundle --file=$HOME/Brewfile
  fi
}

configure_dotfiles() {
  # clone dotfiles if they're missing
  if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone git@github.com:marcuslyons/dotfiles.git $HOME/.dotfiles

    # symlink dotfiles
    echo "Symlinking dotfiles..."
    ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
    ln -s $HOME/.dotfiles/.gitconfig_global $HOME/.gitconfig
    ln -s $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
  fi
}

configure_directories() {
  # create ~/github if it's missing
  if [ ! -d "$HOME/github" ]; then
    echo "Creating ~/github..."
    mkdir $HOME/github
  fi

  # create ~/Screenshots if it's missing
  if [ ! -d "$HOME/Screenshots" ]; then
    echo "Creating ~/Screenshots..."
    mkdir $HOME/Screenshots
  fi
}

configure_macos() {
  bash ./macos
}

configure_zsh() {

  # install oh-my-zsh if it's missing
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # install you-should-use if it's missing
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/you-should-use" ]; then
    echo "Installing you-should-use..."
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
  fi

  source $HOME/.zshrc
}

system_type=$(uname -s)

if [ "$system_type" = "Darwin" ]; then
  configure_macos
fi

configure_dotfiles
configure_directories
configure_zsh
install_brew
