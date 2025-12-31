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

### Required Programs (Arch Linux)

Install the core programs needed for these dotfiles:

```bash
# Core utilities
sudo pacman -S git starship neovim tig tmux htop the_silver_searcher fd fzf eza jq unzip keychain bat inetutils github-cli bind nnn

# Development tools (optional)
sudo pacman -S aws-cli k9s

# Applications (optional)
sudo pacman -S tailscale pcmanfm-gtk3
flatpak install flathub com.slack.Slack md.obsidian.Obsidian com.spotify.Client

# AUR packages (using yay or paru)
yay -S asdf-vm
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

## installing sway

The following packages are required to run sway on arch linux:

```bash
swayfx

# Screen lock and idle management
swaylock-effects
swayidle

# Color temperature / night light
wlsunset

# Wallpaper
swaybg

# On-screen display (volume/brightness indicators)
swayosd

# Status bar
waybar

# Screenshot tools
grim
slurp
wayfreeze
satty

# Clipboard
wl-clipboard

# Portal backend for wlroots compositors
xdg-desktop-portal-wlr

# Session management
uwsm

swaync

greetd
greetd-tuigreet
```

they can be installed with one line:

```bash
sudo pacman -S swayfx swaylock-effects swayidle wlsunset swaybg swayosd waybar grim slurp wayfreeze satty wl-clipboard xdg-desktop-portal-wlr uwsm mako swaync fuzzel greetd
```

## New instructions using archinstall

To set up a new Arch Linux installation with these dotfiles using `archinstall`, follow these steps:
1. Boot into the Arch Linux live environment.
2. Connect to the internet.
3. Copy `user_configuration.json` from this repository to the live environment.
4. Run `archinstall` with the custom configuration:
   ```bash
   archinstall --config https://raw.githubusercontent.com/gammons/dotfiles/main/user_configuration.json
   ``` 

This will automate the installation process and apply your dotfiles configuration.

### AUR helper installation
To install an AUR helper like `yay`, you can use the following commands:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Dotfiles

To apply the dotfiles after installation, clone this repository and use GNU Stow to symlink the configuration files to your home directory:

```bash
git clone https://github.com/gammons/dotfiles ~/dotfiles
cd ~/dotfiles
stow -d ~/dotfiles -t ~ base
```

### nvim packer

To install `packer.nvim` for Neovim, run the following command:

```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
 ```

### aur packages

To install AUR packages listed in the dotfiles, you can use `yay`:

```bash
yay -S swayfx swaylock-effects
```
