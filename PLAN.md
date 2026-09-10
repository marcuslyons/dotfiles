# Dotfiles Migration Plan: GNU Stow + Cross-Platform (macOS / Omarchy)

## Goals

1. Replace the current manual symlink approach (`bootstrap.sh`) with GNU Stow
2. Support both macOS and Omarchy (Arch Linux + Hyprland) from a single repo
3. Minimize duplication: shared configs live in one place, OS-specific configs are isolated

## Current State

The repo has a flat structure with dotfiles in the root, a `brew/` directory, and a `bootstrap.sh` that manually symlinks a few files. The repo is significantly out of date with what's actually running on macOS. Only macOS is supported.

### Drift: Repo vs Live System

The live `~/.zshrc` has diverged significantly from the repo version:
- Added: git aliases (`gds`, `gu`, `gb`, `gcl`, `gl` with pretty log, worktree aliases)
- Added: Obsidian vault alias (`gr`)
- Added: AWS role assumption functions (`promote_role`, `unset_aws`)
- Changed: Several git aliases differ between repo and live
- The repo `.zshrc` still references oh-my-zsh (commented out), GPG agent (commented out)

The live `~/.gitconfig` has diverged:
- Added: `url.ssh://git@github.com/.insteadOf = https://github.com/`
- Has work email, repo version has no email

### Things not in the repo that should be

| Config | Location | Notes |
|--------|----------|-------|
| Ghostty config | `~/.config/ghostty/config` | Does not exist yet on macOS, but Ghostty is in use (replacing Alacritty) |
| Pi agent config | `~/.pi/agent/` | AGENTS.md, settings.json, boomerang.json, skills/, sounds/, bin/ |
| Volta | `~/.volta/` | Node version manager (replaces nvm/fnm). No config file to stow, just needs install script |
| LazyVim overrides | `~/.config/nvim/lua/` | Currently unmodified starter, but will accumulate overrides |

### Things in the repo that are stale

| File | Status |
|------|--------|
| `.config/.alacritty.yml` | Dead. Switched to Ghostty. |
| `.aliases` | Partially duplicated in `.zshrc`, some macOS-specific |
| `.functions` | Some still useful, some stale |
| `karabiner.edn` | Verify if still in use |
| `brew/Brewfile` | Likely outdated, needs regeneration |
| `brew/archive/` | Historical, can be dropped |
| `bootstrap.sh` | Will be replaced by `install.sh` |
| `starship/starship.toml` | Untracked duplicate of `.config/starship.toml` |
| oh-my-zsh references in `.zshrc` | Commented out, dead weight |

### Files in the repo today

| File | What it does |
|------|-------------|
| `.zshrc` | Shell config (outdated) |
| `.aliases` | Shell aliases (partially stale) |
| `.functions` | Shell functions (partially stale) |
| `.gitconfig_global` | Git user config (outdated) |
| `.gitignore_global` | Global gitignore |
| `.gitignore` | Repo gitignore |
| `.config/.alacritty.yml` | Alacritty terminal config (dead, replaced by Ghostty) |
| `.config/starship.toml` | Starship prompt config |
| `.macos` | macOS system preferences script |
| `karabiner.edn` | Karabiner (Goku) config |
| `brew/Brewfile` | Homebrew packages (outdated) |
| `brew/archive/` | Old Brewfile + lockfile |
| `bootstrap.sh` | Setup script (will be replaced) |
| `starship/starship.toml` | Duplicate (untracked) |

## How GNU Stow Works

Stow treats each top-level directory as a "package." When you run `stow <package>` from the dotfiles root, it creates symlinks in the parent directory (default: `$HOME` if the repo lives at `~/.dotfiles`).

The directory structure inside each package mirrors the target filesystem. For example:

```
~/.dotfiles/git/.gitconfig  -->  symlinks to  ~/.gitconfig
~/.dotfiles/starship/.config/starship.toml  -->  symlinks to  ~/.config/starship.toml
```

## Proposed Directory Structure (Flat Packages)

Each top-level directory is a stow package. `install.sh` selects which packages to stow based on OS detection.

```
dotfiles/
├── PLAN.md
├── README.md
├── LICENSE
├── .gitignore
├── .stow-local-ignore              # Tells stow to skip README, LICENSE, PLAN.md, install.sh, etc.
├── install.sh                       # New bootstrap script (replaces bootstrap.sh)
│
├── zsh/                             # stow zsh (both platforms)
│   ├── .zshrc                       # Thin dispatcher that sources ~/.config/shell/*.sh
│   └── .zprofile                    # Login shell (PATH, Homebrew shellenv on macOS)
│
├── shell/                           # stow shell (both platforms)
│   └── .config/
│       └── shell/
│           ├── aliases.sh           # Cross-platform aliases
│           ├── functions.sh         # Cross-platform functions
│           ├── exports.sh           # Cross-platform exports (EDITOR, PATH, etc.)
│           ├── macos.sh             # macOS-specific (Finder aliases, brew PATH, etc.)
│           └── omarchy.sh           # Omarchy-specific (source omarchy aliases, etc.)
│
├── git/                             # stow git (both platforms)
│   ├── .gitconfig                   # Global git config (shared settings)
│   └── .gitignore_global
│
├── starship/                        # stow starship (both platforms)
│   └── .config/
│       └── starship.toml
│
├── ghostty/                         # stow ghostty (both platforms)
│   └── .config/
│       └── ghostty/
│           └── config               # Ghostty config (on Omarchy: includes shell override to zsh)
│
├── nvim/                            # stow nvim (both platforms)
│   └── .config/
│       └── nvim/
│           └── lua/
│               ├── config/
│               │   ├── options.lua
│               │   ├── keymaps.lua
│               │   └── autocmds.lua
│               └── plugins/
│                   └── custom.lua   # Your plugin specs
│
├── pi/                              # stow pi (both platforms)
│   └── .pi/
│       └── agent/
│           ├── AGENTS.md
│           ├── settings.json
│           ├── boomerang.json
│           ├── sounds/
│           │   └── task-complete.mp3
│           ├── bin/
│           │   └── fd
│           └── skills/              # All skill directories
│               ├── git-commit/
│               ├── github-cli/
│               ├── web-browse/
│               └── ...etc
│
├── karabiner/                       # stow karabiner (macOS only)
│   └── .config/
│       └── karabiner/
│           └── karabiner.edn
│
├── brew/                            # stow brew (macOS only)
│   └── Brewfile                     # Lives in $HOME, used by `brew bundle`
│
├── hypr/                            # stow hypr (Omarchy only)
│   └── .config/
│       └── hypr/
│           └── hyprland.conf        # Your Hyprland overrides
│
└── macos-defaults/                  # Not stowed. Run manually: bash macos-defaults/apply.sh
    └── apply.sh
```

## Shell Config Strategy

The current `.zshrc` is monolithic and stale. The plan:

1. **`.zshrc`** becomes a thin dispatcher that sources modular files from `~/.config/shell/`
2. **OS-specific files** use guards so they're harmless if sourced on the wrong platform
3. **All shell config** lives in the `shell/` stow package

```bash
# .zshrc (thin dispatcher)
for f in ~/.config/shell/*.sh; do
  [ -r "$f" ] && source "$f"
done
```

```bash
# ~/.config/shell/macos.sh
[[ "$(uname)" != "Darwin" ]] && return

# macOS-specific aliases, Homebrew PATH, Finder toggles, etc.
```

```bash
# ~/.config/shell/omarchy.sh
[[ ! -d "$HOME/.local/share/omarchy" ]] && return

# Source Omarchy's aliases (they're zsh-compatible)
source ~/.local/share/omarchy/default/bash/aliases
# Omarchy-specific overrides
```

### What to clean up from the current .zshrc

- Remove: oh-my-zsh references (commented out, dead)
- Remove: GPG agent block (commented out, dead)
- Remove: duplicate aliases that are also in `.aliases`
- Keep and modernize: git aliases (use the live versions, not the repo versions)
- Keep: AWS role functions (move to a work-specific file or keep in aliases)
- Add: volta setup (`export VOLTA_HOME="$HOME/.volta"` and PATH)
- Add: starship init

## Handling Omarchy's Expectations

Key things about Omarchy's config model:

- Configs live in `~/.config/` (standard XDG)
- Omarchy's own files live in `~/.local/share/omarchy/` (don't touch these)
- Your overrides go in `~/.config/hypr/hyprland.conf`, `~/.config/ghostty/config`, etc.
- Omarchy recommends stow for backing up your dotfiles
- Default shell is bash, but terminal can launch zsh (see "zsh on Omarchy" below)

Stow fits naturally here. Your `hypr/`, `ghostty/`, etc. packages create symlinks into `~/.config/` which is exactly where Omarchy looks.

**Potential conflict**: Omarchy's installer creates files in `~/.config/` that would conflict with stow symlinks. Two options:
- `stow --adopt <package>` to pull existing files into your repo, then diff and merge
- Delete the Omarchy-generated config files first, then stow

## Ghostty Config

Ghostty replaces Alacritty on both platforms. Single config file stowed at `~/.config/ghostty/config`.

### Findings (2026-04-06)

**zsh path divergence**: `/usr/bin/zsh` does not exist on macOS 15 Sequoia. zsh lives at `/bin/zsh`. On Omarchy (Arch), zsh is at `/usr/bin/zsh`. Using an absolute path in `command` breaks one platform or the other.

**Solution**: Use `command = zsh` (bare command, no absolute path). Ghostty resolves it via `$PATH`, which works on both platforms. Tested and confirmed on macOS 15.

**Config location divergence**: Ghostty on macOS reads from `~/Library/Application Support/com.mitchellh.ghostty/config`, NOT `~/.config/ghostty/config`. On Linux (Omarchy), it reads `~/.config/ghostty/config` as expected.

The stow package puts the config at `~/.config/ghostty/config` (correct for Omarchy). On macOS, `install.sh` needs to symlink it to the Application Support location:

```bash
link_ghostty_macos() {
  if [ "$OS" != "Darwin" ]; then return; fi
  local src="$HOME/.config/ghostty/config"
  local dest="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  if [ -L "$dest" ]; then return; fi  # already linked
  mkdir -p "$(dirname "$dest")"
  # Back up existing config if it's a real file
  [ -f "$dest" ] && mv "$dest" "$dest.bak"
  ln -s "$src" "$dest"
}
```

This way one config file in the repo serves both platforms.

### Previous options considered (and why they were rejected)
1. **Single config with conditional**: Ghostty doesn't support conditionals
2. **Two ghostty packages** (`ghostty-macos/`, `ghostty-omarchy/`): unnecessary now that `command = zsh` works everywhere
3. **One config, append on Omarchy**: unnecessary
4. **`command = /usr/bin/zsh` everywhere**: Breaks on macOS 15 where `/usr/bin/zsh` doesn't exist

## Pi Agent Config

The `~/.pi/agent/` directory contains your agent personality, settings, skills, sounds, and binaries. This is highly personal and portable across machines.

**What to stow** (the `pi/` package):
- `AGENTS.md` (agent instructions)
- `settings.json` (default model, packages, etc.)
- `boomerang.json` (tool config)
- `sounds/task-complete.mp3`
- `bin/fd`
- `skills/` (all skill directories with SKILL.md and scripts)

**What to NOT stow**:
- `auth.json` (contains credentials, add to .gitignore)
- `sessions/` (ephemeral, machine-specific)
- `.DS_Store`

## Volta

Volta has no config file to stow. It's installed to `~/.volta/` and managed via its own CLI. The `install.sh` script handles it:

```bash
install_volta() {
  if ! command -v volta &>/dev/null; then
    curl https://get.volta.sh | bash
  fi
  # Install default toolchain
  volta install node@lts
  volta install npm@latest
}
```

The shell config needs to include volta's PATH setup:
```bash
# In exports.sh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
```

## install.sh Design

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

OS="$(uname -s)"

# Packages to stow on every platform
COMMON_PACKAGES=(zsh shell git starship ghostty nvim pi)

# OS-specific packages
MACOS_PACKAGES=(karabiner brew)
OMARCHY_PACKAGES=(hypr)

stow_packages() {
  for pkg in "$@"; do
    echo "Stowing $pkg..."
    stow -v -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
  done
}

install_stow() {
  if command -v stow &>/dev/null; then return; fi
  if [ "$OS" = "Darwin" ]; then
    brew install stow
  else
    sudo pacman -S --noconfirm stow
  fi
}

install_volta() {
  if command -v volta &>/dev/null; then return; fi
  curl https://get.volta.sh | bash
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
  volta install node@lts
  volta install npm@latest
}

install_lazyvim() {
  if [ -d "$HOME/.config/nvim/.git" ]; then return; fi
  echo "Installing LazyVim starter..."
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  # Remove starter placeholders so stow can link our overrides
  rm -f "$HOME/.config/nvim/lua/plugins/example.lua"
  rm -f "$HOME/.config/nvim/lua/config/options.lua"
  rm -f "$HOME/.config/nvim/lua/config/keymaps.lua"
  rm -f "$HOME/.config/nvim/lua/config/autocmds.lua"
}

install_homebrew() {
  if [ "$OS" != "Darwin" ]; then return; fi
  if command -v brew &>/dev/null; then return; fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_zsh_omarchy() {
  if [ "$OS" = "Darwin" ]; then return; fi
  if command -v zsh &>/dev/null; then return; fi
  sudo pacman -S --noconfirm zsh
}

create_directories() {
  mkdir -p "$HOME/github"
}

link_ghostty_macos() {
  if [ "$OS" != "Darwin" ]; then return; fi
  local src="$HOME/.config/ghostty/config"
  local dest="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  if [ -L "$dest" ]; then return; fi
  mkdir -p "$(dirname "$dest")"
  [ -f "$dest" ] && mv "$dest" "$dest.bak"
  ln -s "$src" "$dest"
}

# --- Main ---
install_homebrew
install_stow
install_volta
install_zsh_omarchy
install_lazyvim
create_directories

stow_packages "${COMMON_PACKAGES[@]}"

if [ "$OS" = "Darwin" ]; then
  stow_packages "${MACOS_PACKAGES[@]}"
  link_ghostty_macos
  # Install from Brewfile if present
  if [ -f "$HOME/Brewfile" ]; then
    brew bundle --file="$HOME/Brewfile"
  fi
else
  stow_packages "${OMARCHY_PACKAGES[@]}"
fi

echo "Done. Restart your shell or run: exec zsh"
```

## Migration Steps

### Phase 1: Restructure the repo

1. Create the new directory structure (flat package approach recommended to start)
2. Move existing files into their stow packages
3. Add `.stow-local-ignore` to skip `README.md`, `LICENSE`, `PLAN.md`, `install.sh`
4. Clean up stale configs (commented-out oh-my-zsh, GPG, etc.)
5. Remove the duplicate `starship/starship.toml`
6. Delete `bootstrap.sh` (replaced by `install.sh`)

### Phase 2: Validate on macOS

1. Clone to `~/.dotfiles`
2. Run `install.sh`
3. Verify all symlinks point correctly
4. Test shell startup, git config, starship prompt, alacritty

### Phase 3: Add Omarchy configs

1. Set up Omarchy on the other machine
2. Identify which `~/.config/` files you want to manage (start with alacritty, hypr overrides)
3. Use `stow --adopt` to pull Omarchy's generated configs into the repo
4. Split anything that differs between macOS and Omarchy into OS-specific packages
5. Decide on zsh vs bash for Omarchy (or support both with shared `~/.config/shell/`)

### Phase 4: Ongoing workflow

- Edit configs locally, commit, push
- Pull on the other machine, re-run `stow` (or `install.sh`)
- `stow -D <package>` to unstow / remove symlinks cleanly

## Decisions Made

### zsh on Omarchy

**Decision**: Use zsh on both platforms.

Omarchy's entire boot chain (SDDM, `/etc/profile.d/*.sh`, `~/.bash_profile`, `~/.local/share/omarchy/`) depends on bash. Running `chsh -s /usr/bin/zsh` will break the desktop session. The correct approach:

1. **Keep bash as the login shell** (do NOT use `chsh`)
2. **Install zsh**: `omarchy-pkg-install zsh` (or `pacman -S zsh`)
3. **Configure the terminal emulator to launch zsh instead of bash**:
   - Ghostty (Omarchy default as of 3.2.0): add `command = zsh` to `~/.config/ghostty/config` (bare command, not absolute path; see Ghostty Config section)
   - Alacritty: add `[terminal.shell]\nprogram = "/usr/bin/zsh"` to `~/.config/alacritty/alacritty.toml`
4. **Source Omarchy's bash aliases from zsh** (they're compatible): add `source ~/.local/share/omarchy/default/bash/aliases` to `.zshrc`
5. **Optionally rebind Super+Return** in `~/.config/hypr/hyprland.conf` to launch zsh directly:
   ```
   unbind = SUPER, RETURN
   bindd = SUPER, RETURN, ZSH, exec, $terminal --working-directory="$(omarchy-cmd-terminal-cwd)" -e zsh
   ```

The `.zshrc` stow package works on both platforms. On macOS it's the actual login shell; on Omarchy it's the interactive shell launched by the terminal emulator.

### LazyVim Config

**Decision**: Personal overrides live in this repo as a stow package. Install scripts handle LazyVim starter setup idempotently.

Current state: `~/.config/nvim` is the unmodified LazyVim starter (cloned from `LazyVim/starter`). The override points are:

- `lua/config/options.lua` (empty)
- `lua/config/keymaps.lua` (empty)
- `lua/config/autocmds.lua` (empty)
- `lua/plugins/example.lua` (example spec, returns `{}`)

Stow package structure:

```
nvim/
└── .config/
    └── nvim/
        └── lua/
            ├── config/
            │   ├── options.lua      # Your option overrides
            │   ├── keymaps.lua      # Your keymap overrides
            │   └── autocmds.lua     # Your autocmd overrides
            └── plugins/
                └── custom.lua       # Your plugin specs (replaces example.lua)
```

This only manages the personal override files, not the full LazyVim install. The `install.sh` script handles the base setup:

```bash
install_lazyvim() {
  if [ ! -d "$HOME/.config/nvim/.git" ]; then
    echo "Installing LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    # Remove the starter's example plugin file (our stow package replaces it)
    rm -f "$HOME/.config/nvim/lua/plugins/example.lua"
  fi
}
```

Then `stow nvim` symlinks your override files into the existing LazyVim directory. This is idempotent: if LazyVim is already installed, the clone is skipped. If your overrides are already symlinked, stow is a no-op.

**Caveat**: stow will conflict if the target files already exist (e.g., the starter's `options.lua`). The install script should remove the starter's placeholder files before stowing, or use `stow --adopt` to pull them in.

## Open Questions

- [x] **What Omarchy overrides do you already have?** Clean slate. No customizations beyond removing pre-installed apps. No configs to reconcile with `stow --adopt`.
- [x] **Repo location convention?** Keep at `~/github/marcuslyons/dotfiles`. Use `stow -d ~/github/marcuslyons/dotfiles -t ~`. Do NOT clone to `~/.dotfiles`.
- [x] **Ghostty config on macOS?** Resolved. Use `command = zsh` (bare), stow to `~/.config/ghostty/config`, symlink to Application Support on macOS. See Ghostty Config section. Still need to decide on font, theme, keybindings.
- [x] **Karabiner still in use?** Not actively. Daemons running but no config file (`karabiner.json` missing). The `.edn` (Goku) in the repo is aspirational. Keep in repo for later.
- [x] **Brewfile regeneration?** Done (2026-04-06). Dumped current state and removed: alacritty (Ghostty), rbenv, exercism, insomnia (Bruno), stay (conflicts with yabai), warp, mongodb-community@5.0. Node is a brew dependency only; Volta owns the runtime.
- [x] **AWS/work functions?** Drop entirely. `promote_role` and `unset_aws` are dead. `gimme-aws-creds` is the standard now.
- [x] **Pi auth.json?** Gitignore, never stow. Contains credentials.
- [x] **Pi skills with scripts?** Agent handles pip deps at runtime when the skill is first invoked. SKILL.md documents the prerequisites. Keep out of `install.sh`.
