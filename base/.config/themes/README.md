# Themes

This directory contains color themes for the desktop environment. Themes are sourced from [Omarchy](https://omarchy.org) and are primarily configured for Hyprland, so additional configuration files may need to be generated for Sway compatibility.

## Theme Structure

Each theme directory should contain the following files:

### Core Files (usually provided by Omarchy)
- `alacritty.toml` - Terminal colors
- `hyprland.conf` - Hyprland window manager colors
- `hyprlock.conf` - Hyprlock screen locker colors
- `waybar.css` - Status bar styling
- `mako.ini` - Notification daemon colors
- `fuzzel.ini` - Application launcher colors
- `btop.theme` - System monitor colors
- `neovim.lua` - Editor colorscheme
- `swayosd.css` - OSD popup styling
- `walker.css` - Walker launcher styling
- `icons.theme` - Icon theme name
- `backgrounds/` - Wallpaper images
- `background` - Symlink to active wallpaper

### Sway-Specific Files (may need to be generated)
- `sway.conf` - Sway window manager colors (border, titlebar, etc.)
- `swaylock.conf` - Swaylock screen locker configuration
- `tmux.conf` - Tmux status bar and pane colors

### Optional Files
- `kitty.conf` - Kitty terminal colors
- `ghostty.conf` - Ghostty terminal colors
- `chromium.theme` - Browser theme
- `vscode.json` - VS Code theme settings
- `light.mode` - Marker file indicating this is a light theme
- `preview.png` / `theme.png` - Theme preview image

## Missing Configurations Checklist

When adding a new theme, check for and generate these files if missing:

### swaylock.conf
Extract colors from `alacritty.toml` or `hyprlock.conf` and create a swaylock config:
- Background color
- Ring colors (normal, verifying, wrong, clear)
- Inside colors
- Text colors
- Key highlight colors

### sway.conf
Extract colors from `hyprland.conf` and create sway border/titlebar colors:
- `client.focused`
- `client.focused_inactive`
- `client.unfocused`
- `client.urgent`

### tmux.conf
Generate tmux colors based on the theme palette:
- Status bar background/foreground
- Window status colors
- Pane border colors
- Message colors

## Color Extraction

Most themes include color definitions in these files:

1. **alacritty.toml** - Contains full color palette under `[colors.normal]` and `[colors.bright]`
2. **hyprlock.conf** - Contains `$color`, `$inner_color`, `$outer_color`, `$font_color`, `$check_color`
3. **hyprland.conf** - Contains border colors like `col.active_border` and `col.inactive_border`

## Usage

The active theme is determined by the `current` symlink in this directory. Use the `changetheme` script to switch themes:

```bash
changetheme <theme-name>
```

This will:
1. Update the `current` symlink
2. Reload Alacritty configuration
3. Update swaylock config symlink
4. Update tmux config symlink (source from ~/.config/themes/current/tmux.conf)
5. Reload Sway
6. Set the wallpaper from the new theme

## Adding a New Theme

1. Clone/copy the theme to this directory
2. Check for missing Sway-specific files (swaylock.conf, sway.conf)
3. Generate missing files using colors from alacritty.toml or hyprlock.conf
4. Optionally generate tmux.conf for terminal multiplexer theming
5. Test with `changetheme <new-theme>`

## Current Theme Status

All themes now have the required Sway-specific configuration files:
- `sway.conf` - All 25 themes ✓
- `swaylock.conf` - All 25 themes ✓
- `tmux.conf` - All 25 themes ✓
