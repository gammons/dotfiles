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
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
```

### Install the dotfiles

```bash
stow -d ~/.dotfiles -t ~ base
```

## Usage

### Adding new dotfiles

1. Move the file/directory to the appropriate package:
   ```bash
   mv ~/.config/foo ~/.dotfiles/base/.config/foo
   ```

2. Stow the package (if not already stowed):
   ```bash
   stow -d ~/.dotfiles -t ~ base
   ```

### Removing/Unstowing

To remove symlinks:

```bash
stow -D -d ~/.dotfiles -t ~ base
```

### Testing changes

Use the `-n` (dry-run) flag to see what stow will do without making changes:

```bash
stow -n -v -d ~/.dotfiles -t ~ base
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
- Any changes made to files in `~/.dotfiles/` will immediately affect your system
- Original dotfiles are backed up in `~/.dotfiles-backup-YYYYMMDD/`

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

## Automated Arch Linux Installation

This repository includes `automated_install.py`, a fully automated installation script that installs Arch Linux and provisions the system with all required packages, dotfiles, and configuration.

### What It Does

The script performs a complete Arch Linux installation including:

- **Disk Setup**: Creates an encrypted (LUKS) LVM layout with separate root and home partitions
- **Base System**: Installs base packages, kernel, bootloader (systemd-boot with UKI)
- **Packages**: Installs all required packages (sway, waybar, neovim, docker, dev tools, fonts, etc.)
- **Users**: Creates user accounts with sudo access
- **Services**: Enables docker, iwd, systemd-networkd, greetd
- **Provisioning**:
  - Installs yay (AUR helper)
  - Clones dotfiles and runs stow
  - Enables noctalia systemd user service (shell/launcher for sway)
  - Sets zsh as default shell
  - Installs packer.nvim
  - Installs AUR packages (swayfx, swaylock-effects, noctalia-shell)
  - Configures greetd with tuigreet

### Prerequisites

- Arch Linux live ISO (boot from USB or in a VM)
- Network connection
- Target disk (will be wiped!)

### Installation Steps

#### 1. Boot into the Arch Linux live environment

Download the latest [Arch Linux ISO](https://archlinux.org/download/) and boot from it.

#### 2. Connect to the internet

For WiFi:
```bash
iwctl --passphrase 'your-wifi-password' station wlan0 connect your-network-name
```

For Ethernet, it should connect automatically.

Verify connectivity:
```bash
ping -c 3 archlinux.org
```

#### 3. Download the installation files

```bash
curl -LO https://raw.githubusercontent.com/gammons/dotfiles/main/automated_install.py
curl -LO https://raw.githubusercontent.com/gammons/dotfiles/main/user_credentials.json.template
```

#### 4. Create your credentials file

```bash
cp user_credentials.json.template user_credentials.json
nano user_credentials.json  # or use vim
```

Edit the file with your actual passwords:
```json
{
    "encryption_password": "your-disk-encryption-password",
    "users": [
        {
            "username": "grant",
            "!password": "your-user-password",
            "sudo": true,
            "groups": ["wheel", "docker"]
        }
    ]
}
```

#### 5. Identify your target disk

```bash
lsblk
```

Common disk names:
- `/dev/sda` - SATA/USB drives
- `/dev/nvme0n1` - NVMe drives
- `/dev/vda` - Virtual machines

#### 6. Run the installation

Dry run (preview what will happen):
```bash
python automated_install.py --device /dev/sda --dry-run
```

Actual installation:
```bash
python automated_install.py --device /dev/sda
```

Replace `/dev/sda` with your target disk.

**Warning**: This will wipe the target disk completely!

#### 7. Reboot

Once installation completes:
```bash
reboot
```

Remove the installation media when prompted.

### Disk Layout

The script creates the following partition layout:

| Partition | Size | Type | Mount |
|-----------|------|------|-------|
| ESP | 1 GiB | FAT32 | /boot |
| LUKS | remaining | encrypted | - |
| └─ root | 32 GiB | ext4 (LVM) | / |
| └─ home | remaining | ext4 (LVM) | /home |

### Customization

To customize the installation, edit `automated_install.py`:

- **HOSTNAME**: System hostname (default: "archlinux")
- **TIMEZONE**: Your timezone (default: "America/New_York")
- **PACKAGES**: List of packages to install
- **SERVICES**: Services to enable
- **BOOT_SIZE_GIB**: Boot partition size
- **ROOT_SIZE_GIB**: Root volume size

### Testing in a VM

For testing, you can use QEMU:

```bash
# Create a virtual disk
qemu-img create -f qcow2 archtest.qcow2 50G

# Copy OVMF vars (must be writable)
cp /usr/share/ovmf/x64/OVMF_VARS.4m.fd .

# Boot the ISO
qemu-system-x86_64 -enable-kvm \
  -machine q35,accel=kvm \
  -cpu host -m 4096 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/x64/OVMF_CODE.4m.fd \
  -drive if=pflash,format=raw,file=OVMF_VARS.4m.fd \
  -cdrom archlinux-*.iso \
  -drive file=archtest.qcow2,format=qcow2 \
  -boot d
```

### Troubleshooting

If provisioning fails but the system boots, you can run the provisioning steps manually:

```bash
# Install yay
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay && makepkg -si --noconfirm
rm -rf ~/yay

# Clone and apply dotfiles
git clone https://github.com/gammons/dotfiles ~/.dotfiles
cd ~/.dotfiles && stow -d ~/.dotfiles -t ~ base

# Install AUR packages
yay -S swayfx swaylock-effects noctalia-shell

# Enable noctalia (shell/launcher service for sway)
systemctl --user enable noctalia.service

# Install packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
