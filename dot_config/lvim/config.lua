--------------------------------
-- Plugins
--------------------------------

lvim.plugins = {
  { "lunarvim/colorschemes" },
  { "janko/vim-test" },
  { "tpope/vim-fugitive" },
  { "tpope/vim-endwise" },
  { "ntpeters/vim-better-whitespace" },
  {
    "zbirenbaum/copilot-cmp",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      vim.defer_fn(function()
        local has_words_before = function()
          if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
        end

        require("copilot").setup()
        local cmp = require("copilot_cmp")
        cmp.setup({
          mapping = {
            ["<Tab>"] = vim.schedule_wrap(function(fallback)
              if cmp.visible() and has_words_before() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              else
                fallback()
              end
            end),
          },
        })
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
vim.opt.wrap = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.cmd("nnoremap Y Y")
vim.cmd("let g:strip_whitespace_on_save=1")

lvim.keys.normal_mode["<cr>"] = ":nohlsearch<cr>"
lvim.keys.normal_mode["<C-p>"] = "<cmd>Telescope find_files<cr>"

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
