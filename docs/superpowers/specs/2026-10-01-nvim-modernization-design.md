# Neovim config modernization — design

Date: 2026-10-01
Config: `base/.config/nvim/` (Neovim 0.12.5, Arch)

## Goal

Fix two reported bugs and replace the unmaintained, packer-based setup with a
small lazy.nvim config sized to how the editor is used now: general text/notes
editing and git, not active software development.

Success means: no markdown treesitter error, one-Tab path completion, a single
`init.lua` under 200 lines, and every check in "Verification" passing.

## Root causes found

1. **Markdown error** (`treesitter.lua:197: attempt to call method 'range'`):
   nvim-treesitter is pinned to the frozen `master` branch. Its
   `set-lang-from-info-string!` directive (`query_predicates.lua:141`) replaces
   Neovim's built-in one and expects one node per capture. Neovim 0.12 always
   passes a list of nodes, so `get_node_text` receives a table. Commit
   `f5b028c` already wrote the setup code for `main` but left
   `branch = 'master'` in the packer spec, so the fix never took effect.
2. **Tab pressed twice**: `wildmode = {'list', 'longest'}`. The first Tab only
   lists matches; the second completes. Already fixed in the working tree as
   `wildmode = 'list:longest'` (verified headlessly).
3. **Found in audit**: LSP never ran. Servers were set up with
   `vim.lsp.config` but never passed to `vim.lsp.enable`, and none of the
   server binaries are installed. LSP is removed rather than repaired, because
   it isn't needed.

## Decisions

| Topic | Decision |
|---|---|
| Plugin manager | lazy.nvim (replaces unmaintained packer.nvim) |
| Layout | Single `init.lua` (target 150–170 lines) + existing `lua/nvim_tree_on_attach.lua` |
| Colorscheme | `rebelot/kanagawa.nvim`, hardcoded; `~/.config/themes` no longer read |
| LSP | Removed entirely (no lspconfig, no servers, no mason) |
| Completion | Built-in `'autocomplete'` (0.12); no completion plugin |
| Formatting | None on save (vim-prettier removed) |
| Commenting | Built-in `gc`/`gcc`; `<C-_>` mapped to them |
| Checkbox | Small markdown-only function on `,tt`, replacing vim-checkbox |

## Plugin set

Kept:

- `folke/lazy.nvim`
- `rebelot/kanagawa.nvim`: `lazy = false`, `priority = 1000`, `config` runs `vim.cmd.colorscheme('kanagawa')`
- `nvim-treesitter/nvim-treesitter`: `branch = 'main'`, `lazy = false`, `build = ':TSUpdate'`
- `nvim-telescope/telescope.nvim` + `nvim-lua/plenary.nvim`
- `nvim-tree/nvim-tree.lua` + `nvim-tree/nvim-web-devicons`
- `nvim-lualine/lualine.nvim`
- `tpope/vim-fugitive`, `tpope/vim-surround`
- `ntpeters/vim-better-whitespace`
- `github/copilot.vim`

Removed: packer.nvim, nvim-compe, popup.nvim, nvim-lspconfig, nerdcommenter,
vim-prettier, html5.vim, vim-javascript, typescript-vim, vim-svelte,
vim-checkbox, vim-test, vim-rails, vim-endwise, vim-doge, CopilotChat.nvim,
nvim-base16, all theme plugins pulled in by the theme scraper (including
LazyVim).

## init.lua structure

In this order. Everything the plugins read when they load (leader, globals,
the `<Tab>` map) comes before the lazy.nvim bootstrap.

1. **Leader and globals**: `mapleader = ','`, `loaded_netrw = 1`,
   `loaded_netrwPlugin = 1`, `g:strip_whitespace_on_save = 1`.
2. **Options**: same as today, including `wildmode = 'list:longest'`, plus
   `autocomplete = true`. Keep `completeopt = 'menuone,noselect'`.
3. **Keymaps and commands**: same as today, except:
   - `<C-_>`: `gcc` in normal mode, `gc` in visual mode (`remap = true`).
   - Remove `,r` `,a` `,t` (vim-test).
   - Keep the insert-mode `<Tab>`/`<S-Tab>` `pumvisible` maps. copilot.vim reads
     the existing `<Tab>` map when it loads and uses it as its fallback, so
     these maps must be defined before `require('lazy').setup()`. The Tab
     check below confirms this.
   - Keep `:Wq`.
4. **Autocmds**:
   - `FileType *`: `pcall(vim.treesitter.start, buf)`.
   - `FileType markdown,gitcommit`: `vim.bo.autocomplete = false` (replaces the
     compe disable).
   - `FileType markdown`: buffer-local `,tt` mapped to the checkbox toggle.
5. **lazy.nvim bootstrap**: clone into `stdpath('data')/lazy/lazy.nvim` if
   missing, prepend it to `runtimepath`, then `require('lazy').setup({...})`
   with the plugin set above. Plugin config lives in each spec's
   `opts`/`config`:
   - lualine: same `options` and `sections` as today, minus the `nvim_lsp`
     diagnostics source (no LSP).
   - nvim-tree: same `setup` as today, `on_attach` from
     `require('nvim_tree_on_attach')`, which is currently a global. Keep it
     working as-is; only change it if lazy loading breaks the global.
   - telescope: `file_sorter = get_fzy_sorter`, as today.
   - treesitter: `require('nvim-treesitter').install({...parsers})`. Parsers:
     markdown, markdown_inline, lua, vim, vimdoc, query, bash, json, yaml,
     toml, gitcommit, diff, html, css, javascript, typescript, ruby, go,
     python, sql.

### Checkbox toggle

Toggles the first `[ ]` / `[x]` on the current line:

```lua
local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local new = line:gsub('%[ %]', '[x]', 1)
  if new == line then new = line:gsub('%[[xX]%]', '[ ]', 1) end
  vim.api.nvim_set_current_line(new)
end
```

## Files

- Rewrite: `base/.config/nvim/init.lua`
- Add: `base/.config/nvim/lazy-lock.json` (generated by lazy.nvim)
- Delete: `base/.config/nvim/plugin/packer_compiled.lua`, `base/.config/nvim/README.md`
- Unchanged: `base/.config/nvim/lua/nvim_tree_on_attach.lua`
- Delete after verification (not tracked): `~/.local/share/nvim/site/pack/packer/`

## Migration

1. User runs `sudo pacman -S tree-sitter-cli` (needed by nvim-treesitter `main`).
2. Rewrite `init.lua`; delete `packer_compiled.lua` and `README.md`.
3. `nvim --headless "+Lazy! sync" +qa`, then install parsers headlessly and
   wait for them to finish.
4. Run the verification checks.
5. Only after they all pass: delete the packer directory, then commit
   `init.lua`, `lazy-lock.json` and the deletions in one commit.

Rollback before step 5: `git checkout` the config files; packer's plugin
directory is still on disk.

## Verification

Headless scripts in `/tmp/opencode`, run against the real config:

| Check | Pass condition |
|---|---|
| Clean startup | `nvim --headless +qa` prints nothing on stderr and `:messages` is empty |
| Issue 1 | `.md` with a fenced `lua` block: `get_parser():parse(true)` succeeds and the parser has a `lua` child tree |
| Issue 2 | `:n …/al<Tab>` gives `…/alpha/` after one Tab |
| Colorscheme | `vim.g.colors_name == 'kanagawa'` |
| Tab | `imap <Tab>` is `copilot#Accept(…)` with a `pumvisible` fallback |
| Autocomplete | `vim.bo.autocomplete` is true in `.txt`, false in `markdown` and `gitcommit` |
| Comment | `<C-_>` on `local x = 1` in `.lua` gives `-- local x = 1` |
| Checkbox | `,tt` switches `- [ ] a` → `- [x] a` → `- [ ] a` in markdown; no `,tt` map in a `.txt` buffer |
| Old plugins gone | no `packer`, `compe` or `lspconfig` path on `runtimepath` |
| Size | `init.lua` under 200 lines |

If a check fails, debug that failure before making any other change.
