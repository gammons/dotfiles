-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- File finding with Ctrl-P (like old config with NERDTree)
-- LazyVim uses snacks.nvim for file picking
map("n", "<C-p>", function()
  require("snacks").picker.files()
end, { desc = "Find Files" })

-- Clear search highlight with Enter
map("n", "<cr>", ":nohlsearch<cr>", { desc = "Clear Search Highlight" })

-- Comment toggle with Ctrl-/ (Ctrl-_ is same as Ctrl-/)
map({ "n", "v" }, "<C-_>", "gcc", { remap = true, desc = "Toggle Comment" })
map({ "n", "v" }, "<C-/>", "gcc", { remap = true, desc = "Toggle Comment" })

-- Edit file in same directory
map("n", "<Leader>e", ":e <C-R>=expand('%:p:h') . '/'<CR>", { desc = "Edit file in same dir" })

-- Split file in same directory
map("n", "<Leader>s", ":split <C-R>=expand('%:p:h') . '/'<CR>", { desc = "Split file in same dir" })

-- Testing shortcuts (if using vim-test or neotest)
map("n", "<Leader>r", "<cmd>TestFile<CR>", { desc = "Test File" })
map("n", "<Leader>a", "<cmd>TestSuite<CR>", { desc = "Test Suite" })
map("n", "<Leader>t", "<cmd>TestNearest<CR>", { desc = "Test Nearest" })

-- Neo-tree toggle with Leader-n (replacing NERDTree)
map("n", "<leader>n", function()
  require("neo-tree.command").execute({ toggle = true })
end, { desc = "Toggle File Explorer" })

-- Quick save and quit with Leader-w
map("n", "<leader>w", "<cmd>wq!<cr>", { desc = "Save and Quit" })

-- LSP keymaps (override LazyVim defaults to match old config)
map("n", "<leader>d", vim.lsp.buf.type_definition, { desc = "Type Definition" })
