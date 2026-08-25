-- LazyVim plugin spec: inject Bauhaus palette into Tokyonight
-- Place this file under LazyVim's plugin specs (Omarchy will copy/link when applying the theme)
return {
  {
    "somerocketeer/bauhaus.nvim",
    name = "bauhaus-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bauhaus").setup({ transparent = false })
      vim.cmd.colorscheme("bauhaus")
    end,
  },
}
