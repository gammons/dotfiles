# Themes

This directory contains color themes for the desktop environment. Themes are sourced from [Omarchy](https://omarchy.org) and are primarily configured for Hyprland, so additional configuration files may need to be generated for Sway compatibility.

## Theme Structure

Each theme directory should contain the following files:

### Core Files (usually provided by Omarchy)
- `alacritty.toml` - Terminal colors
- `ghostty.conf` - Ghostty terminal colors (primary terminal)
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

### Files That May Need To Be Generated
- `sway.conf` - Sway window manager colors (border, titlebar, etc.)
- `swaylock.conf` - Swaylock screen locker configuration
- `tmux.conf` - Tmux status bar and pane colors
- `ghostty.conf` - Ghostty terminal colors (some upstream themes ship none)

### Optional Files
- `kitty.conf` - Kitty terminal colors
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

### ghostty.conf
Convert `alacritty.toml` (or the theme's own `colors.toml`) into Ghostty's format:
- `background` / `foreground`
- `cursor-color` / `cursor-text`
- `selection-background` / `selection-foreground`
- `palette = 0..15=#rrggbb`

Keep it colors-only. `~/.config/ghostty/config` owns font, padding and opacity;
theme files that also set those will leak non-color settings into that theme.

### neovim.lua
`~/.config/nvim/init.lua` only applies a colorscheme when a spec in the returned
list has `opts.colorscheme` (a string or a function). Upstream themes that only
call `vim.cmd.colorscheme(...)` inside `config = function()` will install their
plugin but never apply it, so append a block like:

```lua
{
  "LazyVim/LazyVim",
  opts = { colorscheme = "<name>" },
},
```

Two further traps:

- init.lua scrapes plugin paths out of the raw file text, **including inside Lua
  comments**, and feeds them to packer. Strip commented-out alternative themes or
  packer will install them all.
- Each spec's own `opts` and `config` are discarded. When several themes share
  one colorscheme plugin (e.g. `bjarneo/aether.nvim`), a plain
  `colorscheme = "aether"` makes them all render with the plugin's default
  palette. Use a function instead so the palette is applied at switch time:

  ```lua
  opts = {
    colorscheme = function()
      require("aether").setup({ colors = colors })
      vim.cmd.colorscheme("aether")
    end,
  },
  ```

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
3. Reload Ghostty (SIGUSR2)
4. Update swaylock config symlink
5. Update tmux config symlink (source from ~/.config/themes/current/tmux.conf)
6. Reload Sway
7. Set the wallpaper from the new theme

## Adding a New Theme

1. Clone the theme into this directory and drop `.git/` plus any repo-only
   assets (`screenshots/`, `img/`)
2. Name the directory after the middle word only: `omarchy-<name>-theme` → `<name>`
3. Check for missing files (ghostty.conf, sway.conf, swaylock.conf, tmux.conf)
4. Generate missing files using colors from alacritty.toml, colors.toml or hyprlock.conf
5. Verify: `ghostty +validate-config`, `sway -C -c <theme>/sway.conf`,
   `fuzzel --check-config --config=<theme>/fuzzel.ini`, `tmux source-file <theme>/tmux.conf`
6. Run `:PackerSync` in nvim so the theme's colorscheme plugin gets installed
7. Test with `changetheme <new-theme>`

## Current Theme Status

35 themes installed. Required files present in all except:
- `archriot` - missing sway.conf, swaylock.conf, tmux.conf, fuzzel.ini
- `catppu_mocha` - missing sway.conf, swaylock.conf, tmux.conf, fuzzel.ini

### Known palette overlaps
- `rainynight` uses the Catppuccin Mocha palette in the terminal, so it looks
  identical to `catppuccin` there; its wallpapers and neovim colors differ.
