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
- spotify
- obsidian
- slack-desktop-wayland
- tailscale
- zoom

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
- xf86-video-intel
- brightnessctl
- nerd-fonts-complete
- github-cli
- python-gobject (for gammastep-indicator)
- gammastep
- swaybg
- xdg-desktop-portal-wlr # for screen sharing in chrome, zoom
- noto-fonts-emoji

- vulkan-radeon
- libva-mesa-driver
- light

- slurp
- grim
- wl-clipboard

## Developer-y stuff

- postgresql-libs
- mysql-clients
- docker
- docker-compose
- docker-buildx

(archcraft-specific)
- foot
- mpd
- qt5-wayland

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
