# Dotfiles

Simple dotfiles, rebooted for the umpteenth time.

## Required programs

- git
- starship
- neovim
- tig
- tmux
- htop
- ag
- fd
- fzf
- exa
- jq
- unzip
- keychain
- asdf-vm
- bat
- inetutils # for telnet
- github-cli
- dnsutils
- nnn

## Applications

### Fedora Flatpak apps
```bash
# Desktop applications
flatpak install -y flathub com.slack.Slack
flatpak install -y flathub md.obsidian.Obsidian  
flatpak install -y flathub com.spotify.Client
```

### Other applications needed
- tailscale
- zoom  
- pcmanfm-gtk3 # for a lightweight file manager

## MacOS-specific stuff

- hammerspoon
- scroll-reverser
- shottr - for screenshots
- asdf
- stats
- bat
- bartender

## arch-specific WM stuff

- polkit
- kitty
- dunst
- networkmanager (be sure to enable it with systemd
- network-manager-applet
- waybar
- wofi
- cpupower
- ntp

- pavucontrol
- pulseaudio-bluetooth
- bluez
- bluez-utils

- sway
- swaylock-effects
- swayidle
- swaync
- xf86-video-intel
- brightnessctl
- nerd-fonts-complete
- github-cli
- python-gobject (for gammastep-indicator)
- gammastep
- swaybg
- xdg-desktop-portal-wlr # for screen sharing in chrome, zoom
- noto-fonts-emoji
- ttf-noto-nerd

- vulkan-radeon
- libva-mesa-driver
- light

- slurp
- grim
- wl-clipboard
- swappy

- wireplumber
- libwireplumber
- xdg-desktop-portal-hyprland

## fedora-specific WM stuff

```bash
# Basic packages
sudo dnf install -y git neovim tig tmux htop the_silver_searcher fd-find fzf jq unzip keychain bat gh bind-utils nnn

# WM utilities and system tools
sudo dnf install -y kitty dunst NetworkManager network-manager-applet waybar wofi cpupower chrony

# Audio and bluetooth
sudo dnf install -y pavucontrol pulseaudio-utils bluez bluez-tools

# Sway and related packages
sudo dnf install -y sway swaylock swayidle swaybg xdg-desktop-portal-wlr brightnessctl

# Screenshot and display utilities
sudo dnf install -y slurp grim wl-clipboard gammastep light

# Fonts and additional utilities
sudo dnf install -y google-noto-emoji-fonts google-noto-sans-fonts wireplumber polkit pcmanfm swappy

# Install starship prompt
mkdir -p ~/.local/bin
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin --yes

# Developer tools
sudo dnf install -y docker docker-compose postgresql mysql redis kubernetes-client awscli2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Install k9s (Kubernetes CLI manager)
curl -sL https://github.com/derailed/k9s/releases/download/v0.32.6/k9s_Linux_amd64.tar.gz -o /tmp/k9s.tar.gz
tar -xzf /tmp/k9s.tar.gz -C /tmp && sudo cp /tmp/k9s /usr/local/bin/
```

Note: `eza` is the successor to `exa` and can be installed from cargo or built from source. A C compiler is required for building some packages. After installing Docker, you'll need to log out and back in for the group changes to take effect.

## Hyprland

- cpio
- hyprpm

## Developer-y stuff

See the Fedora installation section above for Docker, PostgreSQL, MySQL, and Redis setup.

(archcraft-specific)
- foot
- mpd
- qt5-wayland

### stuff for ruby development

make sure to run `gem install rubocop-performance rubocop-rails rubocop-rspec` or else the vim plugin will complain

### post-install notes

Run this to make sure vim lsp stuff works:

```
npm install -g diagnostic-languageserver vscode-langservers-extracted
```

systemctl enable systemd-timesyncd

### set chrome as default opener

xdg-settings set default-web-browser chrome.desktop

### app store

- get easyres to change resolution of screen

### Things to get done


- [x] vim background should be black to take advantage of oled
- [x] mpd in swaybar - change to playerctl
- [x] hyprland black background
- [x] locker script
- [x] thinkorswim
- [x] swaybar spaces switcher in hyprland doesn't work
- [ ] networkmanager vpn issues
- [x] scratchpad in Hyprland
- [ ] resize windows with keyboard

- [ ] gammastep
- [x] fix tpm error

### Laptop TLP settings

https://knowledgebase.frame.work/en_us/optimizing-fedora-battery-life-r1baXZh

### nvim gets screwed up

If you're seeing errors like "invalid node type at position 195 for language bash" - run `TSUpdate` which fixed it last time

### Set the correct time

    sudo systemctl enable systemd-timesyncd
    sudo systemctl start systemd-timesyncd
