#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

OS="$(uname -s)"

# Common Packages
# COMMON_PACKAGES=(zsh shell git starship ghostty nvim agents)
COMMON_PACKAGES=(git starship ghostty nvim)

# OS specific packages
MACOS_PACKAGES=(karabiner brew)
OMARCHY_PACKAGES=(hypr)

VOLTA_PACKAGES=(node@24 safe-chain antigravity-usage pnpm@lts bun@lts @mariozechner/pi-coding-agent)

stow_packages() {
  for pkg in "$@"; do
    echo "Stowing $pkg..."
    stow -v -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
  done
}

install_stow() {
  if command -v stow &>/dev/null; then return; fi
  echo "Installing stow..."
  if [ "$OS" = "Darwin" ]; then
    brew install stow
  else
    sudo pacman -S --noconfirm stow
  fi
}

install_volta() {
  if command -v volta &>/dev/null; then return; fi
  echo "Installing Volta..."
  curl https://get.volta.sh | bash
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"

  for pkg in "$@"; do
    echo "Installing $pkg..."
    volta install "$pkg"
  done
}

install_lazyvim() {
  if [ -f "$HOME/.config/nvim/lazyvim.json" ]; then return; fi
  echo "Installing LazyVim starter..."
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"

  # remove placeholders so stow can link
  NVIM_CONFIG_DIR="$HOME/.config/nvim"
  rm -rf "$NVIM_CONFIG_DIR/.git"
  rm -rf "$NVIM_CONFIG_DIR/lua/plugins/example.lua"
  rm -rf "$NVIM_CONFIG_DIR/lua/config/options.lua"
  rm -rf "$NVIM_CONFIG_DIR/lua/config/keymaps.lua"
  rm -rf "$NVIM_CONFIG_DIR/lua/config/autocmds.lua"
}

install_homebrew() {
  if [ "$OS" != "Darwin" ]; then return; fi
  if command -v brew &>/dev/null; then return; fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_zsh_omarchy() {
  if [ "$OS" = "Darwin" ]; then return; fi
  if command -v zsh &>/dev/null; then return; fi
  echo "Installing zsh..."
  sudo pacman -S --noconfirm zsh
}

create_directories() {
  echo "Creating directories..."
  mkdir -p "$HOME/github"
}

link_ghostty_macos() {
  if [ "$OS" != "Darwin" ]; then return; fi
  local src="$HOME/.config/ghostty/config"
  local dest="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  if [ -L "$dest" ]; then return; fi

  echo "Linking ghostty..."
  mkdir -p "$(dirname "$dest")"
  [ -f "$dest" ] && mv "$dest" "$dest.bak"
  ln -s "$src" "$dest"
}

# --- Main ---
install_homebrew
install_stow
install_volta "${VOLTA_PACKAGES[@]}"
install_zsh_omarchy
install_lazyvim
create_directories

stow_packages "${COMMON_PACKAGES[@]}"

if [ "$OS" = "Darwin" ]; then
  stow_packages "${MACOS_PACKAGES[@]}"
  link_ghostty_macos

  # Install from Brewfile if present
  if [ -f "$HOME/Brewfile" ]; then
    echo "Installing from Brewfile..."
    brew bundle --file="$HOME/Brewfile"
  fi
else
  stow_packages "${OMARCHY_PACKAGES[@]}"
fi

echo "Done. Restart your shell or run: exec zsh"
