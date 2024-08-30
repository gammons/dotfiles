-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.cmd("nnoremap Y Y")
vim.cmd("command! Wq wq")
vim.opt.wrap = true -- Disable line wrap
