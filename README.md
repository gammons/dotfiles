# Dotfiles

Personal dotfiles managed with GNU Stow.

## Structure

This repository contains a single package:

- **base** - All configuration files (zsh, git, hypr, waybar, sway, kitty, tmux, nvim, etc.)

## Prerequisites

Install GNU Stow:

```bash
# Arch Linux
sudo pacman -S stow

# Debian/Ubuntu
sudo apt install stow

# Fedora
sudo dnf install stow

# macOS
brew install stow
```

## Installation

Clone this repository:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### Install the dotfiles

```bash
stow -d ~/dotfiles -t ~ base
```

## Usage

### Adding new dotfiles

1. Move the file/directory to the appropriate package:
   ```bash
   mv ~/.config/foo ~/dotfiles/base/.config/foo
   ```

2. Stow the package (if not already stowed):
   ```bash
   stow -d ~/dotfiles -t ~ base
   ```

### Removing/Unstowing

To remove symlinks:

```bash
stow -D -d ~/dotfiles -t ~ base
```

### Testing changes

Use the `-n` (dry-run) flag to see what stow will do without making changes:

```bash
stow -n -v -d ~/dotfiles -t ~ base
```

## Neovim Configuration

The nvim package includes LazyVim with custom keybindings that match classic vim muscle memory:

- **Leader key:** `,` (comma)
- **File finder:** `Ctrl-P`
- **Toggle file tree:** `,n`
- **Clear search:** `Enter`
- **Comment toggle:** `Ctrl-/`
- **Neo-tree:** Press `o` to open files/toggle directories (NERDTree-style)

See `nvim/.config/nvim/lua/config/keymaps.lua` for all custom keybindings.

## Branches

- **main** - Base configuration converted from chezmoi
- **omarchy** - Configuration for omarchy desktop environment with live system files

## Notes

- Symlinks will point to the dotfiles repo location
- Any changes made to files in `~/dotfiles/` will immediately affect your system
- Original dotfiles are backed up in `~/dotfiles-backup-YYYYMMDD/`
