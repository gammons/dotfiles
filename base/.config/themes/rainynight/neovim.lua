-- Upstream declared its palette using aether's v2 base16 keys (base00..base0F),
-- but the installed bjarneo/aether.nvim tracks v3, which ignores them and falls
-- back to aether's own default palette. The same colors are translated to the
-- v3 key names below.
--
-- Several themes here share aether.nvim, and init.lua only runs
-- `opts.colorscheme` (discarding each spec's `opts`/`config`), so the palette is
-- applied from inside the colorscheme function.
local colors = {
  bg         = "#0d0f1a", -- base00 Deep night background
  dark_bg    = "#161822", -- base01 Window frame tone
  darker_bg  = "#080911",
  lighter_bg = "#1e2030", -- base02 Selection / subtle contrast

  fg         = "#d7dbf0", -- base05 City lights reflection
  dark_fg    = "#c7cbe0", -- base04 Soft grey-blue
  light_fg   = "#eef1ff", -- base06 Light desaturated text
  bright_fg  = "#ffffff", -- base07
  muted      = "#555666", -- base03 Comments / dim text

  red        = "#d46a6a", -- base08 Building signals
  orange     = "#d89c66", -- base09 Lamp-like warm orange
  yellow     = "#e0d27d", -- base0A Street reflections
  green      = "#7fa693", -- base0B Desaturated green
  cyan       = "#8ec7d6", -- base0C Light on glass
  blue       = "#8c92c8", -- base0D Rainy sky tone
  purple     = "#bba5d6", -- base0E Neon signs
  brown      = "#c9b88a", -- base0F Warm interior tone

  bright_red    = "#d46a6a",
  bright_yellow = "#e0d27d",
  bright_green  = "#7fa693",
  bright_cyan   = "#8ec7d6",
  bright_blue   = "#8c92c8",
  bright_purple = "#bba5d6",

  accent               = "#8c92c8",
  cursor               = "#d7dbf0",
  foreground           = "#d7dbf0",
  background           = "#0d0f1a",
  selection            = "#1e2030",
  selection_foreground = "#eef1ff",
  selection_background = "#1e2030",
}

return {
  {
    "bjarneo/aether.nvim",
    name = "aether",
    priority = 1000,
    opts = {
      disable_italics = false,
      colors = colors,
    },
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")

      -- Enable hot reload
      require("aether.hotreload").setup()
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("aether").setup({ colors = colors })
        vim.cmd.colorscheme("aether")
      end,
    },
  },
}
