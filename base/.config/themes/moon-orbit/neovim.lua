-- Several themes here share bjarneo/aether.nvim. init.lua only runs
-- `opts.colorscheme`, discarding each spec's own `opts`/`config`, so the
-- palette is applied from inside the colorscheme function below instead --
-- otherwise every aether-based theme renders as aether's default palette.
local colors = {
  bg         = "#2d2940",
  dark_bg    = "#221f30",
  darker_bg  = "#171520",
  lighter_bg = "#423e53",

  fg         = "#6096fd",
  dark_fg    = "#4871be",
  light_fg   = "#78a6fd",
  bright_fg  = "#88b0fe",
  muted      = "#684764",

  red        = "#C0685F",
  yellow     = "#fca766",
  orange     = "#c97f77",
  green      = "#965f81",
  cyan       = "#7c79a5",
  blue       = "#7b79a4",
  purple     = "#987195",
  brown      = "#794c47",

  bright_red    = "#ee897d",
  bright_yellow = "#ffd46b",
  bright_green  = "#bb90a1",
  bright_cyan   = "#a19bd4",
  bright_blue   = "#a09bd3",
  bright_purple = "#c192c0",

  accent               = "#7b79a4",
  cursor               = "#6096fd",
  foreground           = "#6096fd",
  background           = "#2d2940",
  selection            = "#423e53",
  selection_foreground = "#6096fd",
  selection_background = "#423e53",
}

return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#2d2940",
        dark_bg    = "#221f30",
        darker_bg  = "#171520",
        lighter_bg = "#423e53",

        fg         = "#6096fd",
        dark_fg    = "#4871be",
        light_fg   = "#78a6fd",
        bright_fg  = "#88b0fe",
        muted      = "#684764",

        red        = "#C0685F",
        yellow     = "#fca766",
        orange     = "#c97f77",
        green      = "#965f81",
        cyan       = "#7c79a5",
        blue       = "#7b79a4",
        purple     = "#987195",
        brown      = "#794c47",

        bright_red    = "#ee897d",
        bright_yellow = "#ffd46b",
        bright_green  = "#bb90a1",
        bright_cyan   = "#a19bd4",
        bright_blue   = "#a09bd3",
        bright_purple = "#c192c0",

        accent               = "#7b79a4",
        cursor               = "#6096fd",
        foreground           = "#6096fd",
        background           = "#2d2940",
        selection             = "#423e53",
        selection_foreground = "#6096fd",
        selection_background = "#423e53",
      },
    },
    -- set up hot reload
    config = function(_, opts)
      require("aether").setup(opts)
      vim.cmd.colorscheme("aether")
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
