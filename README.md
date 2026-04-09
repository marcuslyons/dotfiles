# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Supports macOS and Omarchy (Arch Linux + Hyprland).

## How it works

Each top-level directory is a stow "package." Running `stow <package>` from the repo root creates symlinks in `$HOME` that mirror the package's internal structure.

```
dotfiles/git/.gitconfig  -->  ~/.gitconfig
dotfiles/nvim/.config/nvim/lua/...  -->  ~/.config/nvim/lua/...
```

```bash
stow -d ~/github/marcuslyons/dotfiles -t ~ <package>
```

## Packages

| Package | Targets | Description |
|---------|---------|-------------|
| `zsh` | both | `.zshrc`, sources modular files from `~/.config/shell/` |
| `shell` | both | Modular shell config: aliases, functions, exports, OS-specific files |
| `git` | both | `.gitconfig`, `.gitignore_global` |
| `starship` | both | Starship prompt config (Catppuccin Mocha palette) |
| `ghostty` | both | Ghostty terminal config |
| `nvim` | both | LazyVim override files (plugins, keymaps, options) |
| `brew` | macOS | Brewfile for `brew bundle` |
| `karabiner` | macOS | Karabiner Elements (Goku) config |

### Not yet migrated

| Package | Status |
|---------|--------|
| `shell` | Directory exists but shell config files haven't been split out yet |
| `hypr` | Omarchy Hyprland overrides (planned) |

## Neovim

Uses [LazyVim](https://www.lazyvim.org/) as the base distribution. The `nvim` stow package only manages personal overrides, not the full LazyVim install.

The full `~/.config/nvim` directory is stowed, including `init.lua`, `lazy-lock.json`, `lazyvim.json`, and the `lua/` tree. LazyVim extras enabled: JSON, Markdown, TypeScript.

Custom plugins:

- `pi.nvim` for AI agent integration
- `noice.nvim` disabled

## Shell architecture

`.zshrc` is a thin dispatcher:

```bash
for f in ~/.config/shell/*.sh; do
  [ -r "$f" ] && source "$f"
done
```

Modular files in `~/.config/shell/` handle aliases, functions, exports, and OS-specific config. OS-specific files guard with early returns (e.g., `[[ "$(uname)" != "Darwin" ]] && return`).

## Setup

### Prerequisites

- macOS or Arch Linux (Omarchy)
- Git
- GNU Stow (`brew install stow` / `pacman -S stow`)

### Install

```bash
git clone git@github.com:marcuslyons/dotfiles.git ~/github/marcuslyons/dotfiles
cd ~/github/marcuslyons/dotfiles

# Stow everything (macOS)
for pkg in zsh shell git starship ghostty nvim brew; do
  stow -t ~ "$pkg"
done

# Or use install.sh when it's ready
./install.sh
```

### Ghostty on macOS

Ghostty reads config from `~/Library/Application Support/com.mitchellh.ghostty/config` on macOS, not `~/.config/ghostty/config`. After stowing, symlink it:

```bash
mkdir -p ~/Library/Application\ Support/com.mitchellh.ghostty
ln -s ~/.config/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

### Unstow a package

```bash
stow -t ~ -D <package>
```

## Key tools

- **[Volta](https://volta.sh/)** for Node.js version management
- **[Starship](https://starship.rs/)** for the shell prompt
- **[Ghostty](https://ghostty.org/)** as the terminal emulator
- **[LazyVim](https://www.lazyvim.org/)** as the Neovim distribution
- **[Homebrew](https://brew.sh/)** for macOS package management

## Migration status

This repo is being migrated from a legacy flat-file structure with a manual `bootstrap.sh` to stow packages.

## License

MIT
