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
- broot
- asdf-vm
- bat
- inetutils # for telnet
- github-cli

## Applications
- spotify
- obsidian
- slack
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

- vulkan-radeon
- libva-mesa-driver
- light

- slurp
- grim
- wl-clipboard

(archcraft-specific)
- foot
- mpd
- qt5-wayland

### post-install notes

Run this to make sure vim lsp stuff works:

```
npm install -g diagnostic-languageserver
```

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


