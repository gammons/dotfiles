# Neovim Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the packer-based Neovim config with a single lazy.nvim `init.lua` (11 plugins), fixing the markdown treesitter error and the double-Tab path completion.

**Architecture:** One `init.lua`, in this order: leader/globals, options, keymaps (including the `<Tab>` map copilot.vim wraps), autocmds, then the lazy.nvim bootstrap and plugin specs. A headless check harness in `/tmp/opencode/nvim-checks` runs the real config and prints PASS/FAIL per behavior. It is written first, run against the old config to show the failures, then run again after the rewrite.

**Tech Stack:** Neovim 0.12.5, lazy.nvim (stable), nvim-treesitter `main` branch, tree-sitter-cli 0.26.x (Arch package), bash.

**Spec:** `docs/superpowers/specs/2026-10-01-nvim-modernization-design.md`

## Global Constraints

- Neovim 0.12.5 on Arch; config dir `~/.config/nvim` = `~/dotfiles/base/.config/nvim` (repo root `~/dotfiles`).
- `init.lua` under 200 lines; no other files under `base/.config/nvim/` except `init.lua` and `lazy-lock.json`.
- Plugins, exactly: lazy.nvim, kanagawa.nvim, nvim-treesitter (`branch = 'main'`), telescope.nvim, plenary.nvim, nvim-tree.lua, nvim-web-devicons, lualine.nvim, vim-fugitive, vim-surround, vim-better-whitespace, copilot.vim.
- No LSP, no completion plugin, no formatter, nothing read from `~/.config/themes`.
- The insert-mode `<Tab>`/`<S-Tab>` maps must be defined before `require('lazy').setup()`.
- Do not delete `~/.local/share/nvim/site/pack/packer/` until every check passes on the new config.
- `sudo` is not available to the agent; the user installs `tree-sitter-cli`.

## Review Focus

1. Markdown fence with an unknown language (` ```foobar `) or no language → no error, the rest of the file still highlights. Covered by `fixtures/fence.md` in `issue1-markdown.lua`.
2. Opening a filetype that has no installed parser (`.rs`) → no error; falls back to regex syntax. Covered by `no-parser.lua`.
3. `,tt` on a line with no checkbox, or with an uppercase `[X]` → no change, and `[X]` → `[ ]`. Covered by `checkbox.lua`.
4. `,n` opens nvim-tree after `on_attach` is removed → tree window opens, no error. Covered by `nvim-tree.lua`.
5. `Ctrl-p` still works after telescope's setup moves into a lazy spec → `:Telescope` exists and `telescope.builtin` loads. Covered by `telescope.lua`.

---

### Task 1: Check harness (tests first)

**Files:**
- Create: `/tmp/opencode/nvim-checks/run.sh`
- Create: `/tmp/opencode/nvim-checks/checks/*.lua` (12 files below)
- Create: `/tmp/opencode/nvim-checks/fixtures/{fence.md,notes.txt,c.lua,x.rs,COMMIT_EDITMSG,wt/alpha/file.md,wt/beta.txt}`

**Interfaces:**
- Produces: `bash /tmp/opencode/nvim-checks/run.sh`, which prints one `STATUS<TAB>name<TAB>detail` line per check, then `failures: N`, and exits with `N`. Each `checks/<name>.lua` runs inside `nvim --headless` with the real config, with cwd = `fixtures/`, and must `return ok, detail`. Any stderr output from that nvim run makes the check FAIL.

- [ ] **Step 1: Create fixtures**

```bash
mkdir -p /tmp/opencode/nvim-checks/checks /tmp/opencode/nvim-checks/fixtures/wt/alpha
cd /tmp/opencode/nvim-checks/fixtures
touch wt/alpha/file.md wt/beta.txt
printf 'plain notes\n' > notes.txt
printf 'local x = 1\n' > c.lua
printf 'fn main() {}\n' > x.rs
printf 'subject line\n' > COMMIT_EDITMSG
```

Create `/tmp/opencode/nvim-checks/fixtures/fence.md` with exactly:

~~~markdown
# Title

Some *text* and `code`.

```lua
local x = 1
```

```foobar
unknown language
```

```
no language
```

- [ ] item
~~~

- [ ] **Step 2: Create the runner `/tmp/opencode/nvim-checks/run.sh`**

```bash
#!/usr/bin/env bash
# Runs every check against the real nvim config. Exit code = number of failures.
set -u
D=/tmp/opencode/nvim-checks
CFG=$HOME/.config/nvim
fails=0

report() { # status name detail
  printf '%s\t%s\t%s\n' "$1" "$2" "$3"
  [[ $1 == PASS ]] || fails=$((fails + 1))
}

err=$(cd "$D/fixtures" && nvim --headless +qa 2>&1)
if [[ -z $err ]]; then report PASS startup-stderr ""; else report FAIL startup-stderr "$err"; fi

lines=$(wc -l < "$CFG/init.lua")
if (( lines < 200 )); then report PASS size "$lines lines"; else report FAIL size "$lines lines"; fi

for f in "$D"/checks/*.lua; do
  name=$(basename "$f" .lua)
  out=$(cd "$D/fixtures" && nvim --headless \
    -c "lua local s, ok, d = pcall(dofile, '$f'); if not s then ok, d = false, ok end; io.stdout:write((ok and 'PASS' or 'FAIL') .. '|' .. tostring(d or ''))" \
    -c 'qa!' 2>"$D/$name.stderr")
  status=${out%%|*}
  detail=${out#*|}
  if [[ -s $D/$name.stderr ]]; then
    status=FAIL
    detail="$detail stderr: $(head -c 300 "$D/$name.stderr")"
  fi
  report "${status:-FAIL}" "$name" "$detail"
done

echo "failures: $fails"
exit "$fails"
```

Run: `chmod +x /tmp/opencode/nvim-checks/run.sh`

- [ ] **Step 3: Create the spec checks**

`checks/messages.lua`
```lua
local out = vim.api.nvim_exec2('messages', { output = true }).output
return out == '', out
```

`checks/issue1-markdown.lua`
```lua
vim.cmd.edit('fence.md')
local parser = vim.treesitter.get_parser(0)
parser:parse(true)
local hl = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
local has_lua = parser:children().lua ~= nil
return hl and has_lua, ('highlighter=%s lua_child=%s'):format(hl, has_lua)
```

`checks/issue2-wildmode.lua`
```lua
vim.cmd('cnoremap <expr> <F2> execute("let g:c = getcmdline()")[-1]')
vim.api.nvim_feedkeys(vim.keycode(':n wt/al<Tab><F2><C-c>'), 'xt', false)
return vim.g.c == 'n wt/alpha/', tostring(vim.g.c)
```

`checks/colorscheme.lua`
```lua
return vim.g.colors_name == 'kanagawa', tostring(vim.g.colors_name)
```

`checks/tab.lua`
```lua
local rhs = vim.fn.maparg('<Tab>', 'i', false, true).rhs or ''
local ok = rhs:find('copilot#Accept', 1, true) ~= nil and rhs:find('pumvisible', 1, true) ~= nil
return ok, rhs
```

`checks/autocomplete.lua`
```lua
local function ac(file) vim.cmd.edit(file); return vim.o.autocomplete end
local txt, md, gc = ac('notes.txt'), ac('fence.md'), ac('COMMIT_EDITMSG')
return txt and not md and not gc, ('txt=%s md=%s gitcommit=%s'):format(txt, md, gc)
```

`checks/comment.lua`
```lua
vim.cmd.edit('c.lua')
vim.api.nvim_feedkeys(vim.keycode('<C-_>'), 'x', false)
local line = vim.api.nvim_get_current_line()
return line == '-- local x = 1', line
```

`checks/checkbox.lua`
```lua
vim.cmd.edit('fence.md')
local function tt(text)
  vim.api.nvim_set_current_line(text)
  vim.api.nvim_feedkeys(',tt', 'x', false)
  return vim.api.nvim_get_current_line()
end
local r1, r2, r3, r4 = tt('- [ ] a'), tt('- [x] a'), tt('- [X] a'), tt('plain line')
vim.cmd.edit('notes.txt')
local txt_map = vim.fn.maparg(',tt', 'n')
local ok = r1 == '- [x] a' and r2 == '- [ ] a' and r3 == '- [ ] a'
  and r4 == 'plain line' and txt_map == ''
return ok, table.concat({ r1, r2, r3, r4, 'txt_map=' .. txt_map }, ' | ')
```

`checks/old-plugins.lua`
```lua
local bad = {}
for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
  if p:find('packer') or p:find('compe') or p:find('lspconfig') or p:find('LazyVim') then
    table.insert(bad, p)
  end
end
return #bad == 0, table.concat(bad, ', ')
```

- [ ] **Step 4: Create the Review Focus checks**

`checks/no-parser.lua`
```lua
vim.cmd.edit('x.rs')
return vim.bo.filetype == 'rust' and vim.v.errmsg == '',
  ('ft=%s errmsg=%s'):format(vim.bo.filetype, vim.v.errmsg)
```

`checks/nvim-tree.lua`
```lua
vim.cmd('NvimTreeToggle')
local found = false
for _, w in ipairs(vim.api.nvim_list_wins()) do
  if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'NvimTree' then found = true end
end
return found, 'NvimTree window ' .. (found and 'open' or 'missing')
```

`checks/telescope.lua`
```lua
local ok = vim.fn.exists(':Telescope') == 2 and pcall(require, 'telescope.builtin')
return ok, 'Telescope command + telescope.builtin'
```

(The markdown unknown-fence and checkbox edge cases are already in `fence.md`, `issue1-markdown.lua` and `checkbox.lua`.)

- [ ] **Step 5: Run against the OLD config and confirm it fails for the right reasons**

Run: `bash /tmp/opencode/nvim-checks/run.sh`

Expected: non-zero exit. These must be FAIL:
- `issue1-markdown`: detail contains `attempt to call method 'range'`
- `autocomplete`: `txt=false`
- `old-plugins`: lists packer / compe / lspconfig / LazyVim paths
- `size`: `415 lines`

`issue2-wildmode` must PASS (the `wildmode` fix is already in the working tree). Record the other results as the baseline. `colorscheme` may FAIL only because the old config sets it inside `vim.schedule`; that's fine. Any FAIL whose detail doesn't match the reasons above means a broken check: fix the check before moving on.

No commit: the harness lives outside the repo.

---

### Task 2: Rewrite init.lua on lazy.nvim

**Files:**
- Rewrite: `~/dotfiles/base/.config/nvim/init.lua`
- Delete: `~/dotfiles/base/.config/nvim/plugin/packer_compiled.lua`
- Delete: `~/dotfiles/base/.config/nvim/README.md`
- Delete: `~/dotfiles/base/.config/nvim/lua/nvim_tree_on_attach.lua`
- Generated: `~/dotfiles/base/.config/nvim/lazy-lock.json`

**Interfaces:**
- Consumes: `run.sh` from Task 1.
- Produces: a working config plus `lazy-lock.json`; parsers in `~/.local/share/nvim/site/parser/`.

- [ ] **Step 1: User installs tree-sitter-cli**

Ask the user to run `sudo pacman -S tree-sitter-cli`, then verify:

Run: `tree-sitter --version`
Expected: `tree-sitter 0.26.x` (any version ≥ 0.26.1). Do not continue until this passes.

- [ ] **Step 2: Replace `init.lua` with exactly this content**

```lua
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

-- Must exist before copilot.vim loads: it wraps this map as its <Tab> fallback
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
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install({
        'markdown', 'markdown_inline', 'lua', 'vim', 'vimdoc', 'query',
        'bash', 'json', 'yaml', 'toml', 'gitcommit', 'diff',
        'html', 'css', 'javascript', 'typescript', 'ruby', 'go', 'python', 'sql',
      })
    end,
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
  'github/copilot.vim',
}, {
  install = { colorscheme = { 'kanagawa', 'habamax' } },
})
```

- [ ] **Step 3: Delete the obsolete files**

```bash
cd ~/dotfiles
git rm -q base/.config/nvim/plugin/packer_compiled.lua base/.config/nvim/README.md base/.config/nvim/lua/nvim_tree_on_attach.lua
```

- [ ] **Step 4: Install plugins**

Run: `nvim --headless "+Lazy! sync" +qa`
Expected: exits 0; `ls ~/.local/share/nvim/lazy` lists exactly: `copilot.vim kanagawa.nvim lazy.nvim lualine.nvim nvim-tree.lua nvim-treesitter nvim-web-devicons plenary.nvim telescope.nvim vim-better-whitespace vim-fugitive vim-surround`; `~/dotfiles/base/.config/nvim/lazy-lock.json` exists.

- [ ] **Step 5: Install parsers and wait for them**

Starting nvim kicks off the async install from the treesitter `config`; this waits until all 20 parsers exist:

Run: `nvim --headless -c 'lua vim.wait(300000, function() return #vim.fn.glob(vim.fn.stdpath("data") .. "/site/parser/*.so", false, true) >= 20 end, 1000)' -c 'qa'`
Then: `ls ~/.local/share/nvim/site/parser | wc -l`
Expected: `20`. If fewer, start `nvim`, run `:checkhealth nvim-treesitter`, and fix what it reports before continuing.

- [ ] **Step 6: Run the checks**

Run: `bash /tmp/opencode/nvim-checks/run.sh`
Expected: all 14 lines `PASS`, then `failures: 0`. `old-plugins` passes even though the packer directory still exists, because lazy.nvim resets `packpath` so `site/pack/packer` is never loaded.

If anything fails, use superpowers:systematic-debugging on that specific check. Do not change several things at once.

---

### Task 3: Remove packer, final verification, commit

**Files:**
- Delete (untracked): `~/.local/share/nvim/site/pack/packer/`
- Commit: `base/.config/nvim/init.lua`, `base/.config/nvim/lazy-lock.json`, the three deletions from Task 2

**Interfaces:**
- Consumes: passing `run.sh` from Task 2.

- [ ] **Step 1: Delete the old packer plugin directory**

```bash
rm -rf ~/.local/share/nvim/site/pack/packer
```

- [ ] **Step 2: Re-run the checks**

Run: `bash /tmp/opencode/nvim-checks/run.sh`
Expected: `failures: 0`.

- [ ] **Step 3: Confirm the repo state**

Run: `cd ~/dotfiles && git status --short base/.config/nvim`
Expected: exactly these five entries (in any order) and nothing else:
```
D  base/.config/nvim/README.md
 M base/.config/nvim/init.lua
?? base/.config/nvim/lazy-lock.json
D  base/.config/nvim/lua/nvim_tree_on_attach.lua
D  base/.config/nvim/plugin/packer_compiled.lua
```

- [ ] **Step 4: Commit**

```bash
cd ~/dotfiles
git add base/.config/nvim/init.lua base/.config/nvim/lazy-lock.json
git commit -q -m "nvim: migrate to lazy.nvim, treesitter main, drop LSP and stale plugins

- packer.nvim (unmaintained) -> lazy.nvim, single init.lua
- nvim-treesitter master -> main: fixes markdown 'attempt to call method range'
- wildmode list,longest -> list:longest: one Tab completes paths
- nvim-compe -> built-in 'autocomplete'; nerdcommenter -> built-in gc
- vim-checkbox -> small markdown-only ,tt toggle
- remove never-started LSP setup, theme scraping, and 16 unused plugins"
git log --oneline -1
```
