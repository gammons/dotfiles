--------------------------------
-- Plugins
--------------------------------

lvim.plugins = {
  { "lunarvim/colorschemes" },
  { "janko/vim-test" },
  { "tpope/vim-fugitive" },
  { "ntpeters/vim-better-whitespace" },
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup()     -- https://github.com/zbirenbaum/copilot.lua/blob/master/README.md#setup-and-configuration
        require("copilot_cmp").setup() -- https://github.com/zbirenbaum/copilot-cmp/blob/master/README.md#configuration
      end, 100)
    end,
  }
}
--------------------------------
-- General config
--------------------------------

lvim.colorscheme = "tomorrow"
lvim.format_on_save = true
lvim.leader = ","
vim.cmd("nnoremap Y Y")
vim.cmd("let g:strip_whitespace_on_save=1")

lvim.builtin.project.active = false -- causes issues with fzf searching reverting to home dir

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
