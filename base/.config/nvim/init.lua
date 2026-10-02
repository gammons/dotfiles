-------------------- LEADER & GLOBALS ----------------------
-- Set before lazy.nvim loads so plugin mappings and settings see them
vim.g.mapleader = ','
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.strip_whitespace_on_save = 1

-------------------- OPTIONS -------------------------------
local opt = vim.opt
opt.autocomplete = true             -- Built-in completion menu as you type
opt.completeopt = 'menuone,noselect'
opt.expandtab = true                -- Use spaces instead of tabs
opt.hidden = true                   -- Enable background buffers
opt.backup = false
opt.swapfile = false
opt.ignorecase = true               -- Ignore case
opt.joinspaces = false              -- No double spaces with join
opt.list = true                     -- Show some invisible characters
opt.number = true                   -- Show line numbers
opt.scrolloff = 4                   -- Lines of context
opt.shiftround = true               -- Round indent
opt.shiftwidth = 2                  -- Size of an indent
opt.sidescrolloff = 8               -- Columns of context
opt.smartcase = true                -- Do not ignore case with capitals
opt.smartindent = true              -- Insert indents automatically
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new windows right of current
opt.tabstop = 2                     -- Number of spaces tabs count for
opt.termguicolors = true            -- True color support
opt.wildmode = 'list:longest'       -- Command-line completion mode
opt.wrap = true                     -- Wrap long lines

-------------------- MAPPINGS ------------------------------
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Tab / S-Tab cycle the completion menu when it's visible
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true })
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true })

map('', '<C-p>', '<cmd>Telescope find_files<cr>')
map('', '<cr>', ':nohlsearch<cr>')
map('n', '<C-_>', 'gcc', { noremap = false })
map('x', '<C-_>', 'gc', { noremap = false })

map('', '<Leader>e', ":e <C-R>=expand(\"%:p:h\") . '/'<CR>")
map('', '<Leader>s', ":split <C-R>=expand(\"%:p:h\") . '/'<CR>")
map('', '<Leader>n', '<cmd>NvimTreeToggle<cr>')
map('', '<Leader>w', '<cmd>wq!<cr>')
map('n', 'Y', 'Y')
map('t', '<Esc>', '<C-\\><C-n>')

vim.cmd('command! Wq wq')

-------------------- AUTOCMDS ------------------------------
local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new = line:gsub('%[ %]', '[x]', 1)
  if new == line then new = line:gsub('%[[xX]%]', '[ ]', 1) end
  vim.api.nvim_set_current_line(new)
end

local group = vim.api.nvim_create_augroup('config', { clear = true })

-- Use treesitter highlighting where nvim ships a parser (markdown, lua, vim, ...)
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = { 'markdown', 'gitcommit' },
  callback = function() vim.bo.autocomplete = false end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'markdown',
  callback = function(ev)
    vim.keymap.set('n', '<Leader>tt', toggle_checkbox, { buffer = ev.buf, desc = 'Toggle checkbox' })
  end,
})

-------------------- PLUGINS -------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function() vim.cmd.colorscheme('kanagawa') end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = { file_sorter = require('telescope.sorters').get_fzy_sorter },
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sort = { sorter = 'case_sensitive' },
      view = { width = { min = 30 } },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },
  'tpope/vim-fugitive',
  'tpope/vim-surround',
  'ntpeters/vim-better-whitespace',
}, {
  install = { colorscheme = { 'kanagawa', 'habamax' } },
})
