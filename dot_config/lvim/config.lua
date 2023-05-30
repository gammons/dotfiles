--------------------------------
-- Plugins
--------------------------------

lvim.plugins = {
  { "lunarvim/colorschemes" },
  { "janko/vim-test" },
  { "ntpeters/vim-better-whitespace" },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-l>",
          }
        },
      })
    end,
  },
}
--------------------------------
-- General config
--------------------------------

lvim.colorscheme = "tomorrow"
lvim.format_on_save = true
lvim.leader = ","
vim.cmd("nnoremap Y Y")
vim.cmd("let g:strip_whitespace_on_save=1")

--------------------------------
-- Testing
--------------------------------
lvim.keys.normal_mode["<Leader>r"] = ":TestFile<CR>"
lvim.builtin.which_key.mappings["t"] = {
  name = "Test",
  r = { "<cmd>TestFile<cr>", "File" },
  a = { "<cmd>TestNearest<cr>", "Nearest" },
  t = { "<cmd>TestSuite<cr>", "Suite" },
}
vim.cmd("let test#strategy ='neovim'")
