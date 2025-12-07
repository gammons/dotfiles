" Frost colorscheme for Vim/Neovim
" Maintainer: Frost Theme
" License: MIT

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "frost"

" Color definitions
let background = "#0a0f1c"
let foreground = "#d4d5d9"
let cursor     = "#d4d5d9"

" Colors
let color0  = "#0a0f1c"
let color1  = "#869AAC"
let color2  = "#95A8B8"
let color3  = "#9FADB8"
let color4  = "#9BB0C2"
let color5  = "#A8B9C6"
let color6  = "#B8C7D0"
let color7  = "#d4d5d9"
let color8  = "#5f6374"
let color9  = "#869AAC"
let color10 = "#95A8B8"
let color11 = "#9FADB8"
let color12 = "#9BB0C2"
let color13 = "#A8B9C6"
let color14 = "#B8C7D0"
let color15 = "#d4d5d9"

" Terminal colors
if has('nvim')
  let g:terminal_color_0 = color0
  let g:terminal_color_1 = color1
  let g:terminal_color_2 = color2
  let g:terminal_color_3 = color3
  let g:terminal_color_4 = color4
  let g:terminal_color_5 = color5
  let g:terminal_color_6 = color6
  let g:terminal_color_7 = color7
  let g:terminal_color_8 = color8
  let g:terminal_color_9 = color9
  let g:terminal_color_10 = color10
  let g:terminal_color_11 = color11
  let g:terminal_color_12 = color12
  let g:terminal_color_13 = color13
  let g:terminal_color_14 = color14
  let g:terminal_color_15 = color15
elseif has('terminal')
  let g:terminal_ansi_colors = [
    \ color0, color1, color2, color3,
    \ color4, color5, color6, color7,
    \ color8, color9, color10, color11,
    \ color12, color13, color14, color15
  \ ]
endif

" Basic highlight groups
exe "hi Normal guifg=" . foreground . " guibg=" . background . " ctermfg=7 ctermbg=0"
exe "hi Cursor guifg=" . background . " guibg=" . cursor . " ctermfg=0 ctermbg=7"
exe "hi CursorLine guibg=" . color8 . " ctermbg=8"
exe "hi CursorColumn guibg=" . color8 . " ctermbg=8"
exe "hi LineNr guifg=" . color8 . " ctermfg=8"
exe "hi CursorLineNr guifg=" . color7 . " ctermfg=7"

" Syntax highlighting
exe "hi Comment guifg=" . color8 . " ctermfg=8"
exe "hi String guifg=" . color2 . " ctermfg=2"
exe "hi Number guifg=" . color4 . " ctermfg=4"
exe "hi Constant guifg=" . color5 . " ctermfg=5"
exe "hi Identifier guifg=" . color7 . " ctermfg=7"
exe "hi Function guifg=" . color1 . " ctermfg=1"
exe "hi Statement guifg=" . color1 . " ctermfg=1"
exe "hi PreProc guifg=" . color5 . " ctermfg=5"
exe "hi Type guifg=" . color4 . " ctermfg=4"
exe "hi Special guifg=" . color5 . " ctermfg=5"
exe "hi Keyword guifg=" . color1 . " ctermfg=1"
exe "hi Operator guifg=" . color7 . " ctermfg=7"

" UI elements
exe "hi Visual guibg=" . color8 . " ctermbg=8"
exe "hi Search guifg=" . background . " guibg=" . color11 . " ctermfg=0 ctermbg=11"
exe "hi IncSearch guifg=" . background . " guibg=" . color3 . " ctermfg=0 ctermbg=3"
exe "hi StatusLine guifg=" . foreground . " guibg=" . color8 . " ctermfg=7 ctermbg=8"
exe "hi StatusLineNC guifg=" . color8 . " guibg=" . background . " ctermfg=8 ctermbg=0"
exe "hi VertSplit guifg=" . color8 . " ctermfg=8"
exe "hi Pmenu guifg=" . foreground . " guibg=" . color8 . " ctermfg=7 ctermbg=8"
exe "hi PmenuSel guifg=" . background . " guibg=" . color4 . " ctermfg=0 ctermbg=4"
exe "hi TabLine guifg=" . color8 . " guibg=" . background . " ctermfg=8 ctermbg=0"
exe "hi TabLineFill guibg=" . background . " ctermbg=0"
exe "hi TabLineSel guifg=" . foreground . " guibg=" . color8 . " ctermfg=7 ctermbg=8"

" Diff highlighting
exe "hi DiffAdd guifg=" . color2 . " guibg=" . background . " ctermfg=2 ctermbg=0"
exe "hi DiffChange guifg=" . color3 . " guibg=" . background . " ctermfg=3 ctermbg=0"
exe "hi DiffDelete guifg=" . color1 . " guibg=" . background . " ctermfg=1 ctermbg=0"
exe "hi DiffText guifg=" . color11 . " guibg=" . background . " ctermfg=11 ctermbg=0"

" Error and warning
exe "hi Error guifg=" . color1 . " guibg=" . background . " ctermfg=1 ctermbg=0"
exe "hi Warning guifg=" . color3 . " guibg=" . background . " ctermfg=3 ctermbg=0"
exe "hi ErrorMsg guifg=" . color1 . " ctermfg=1"
exe "hi WarningMsg guifg=" . color3 . " ctermfg=3"

" Folding
exe "hi Folded guifg=" . color8 . " guibg=" . background . " ctermfg=8 ctermbg=0"
exe "hi FoldColumn guifg=" . color8 . " guibg=" . background . " ctermfg=8 ctermbg=0"

" File explorer and tree colors
exe "hi Directory guifg=" . color4 . " ctermfg=4"
exe "hi NvimTreeFolderName guifg=" . color4 . " ctermfg=4"
exe "hi NvimTreeFolderIcon guifg=" . color4 . " ctermfg=4"
exe "hi NvimTreeOpenedFolderName guifg=" . color2 . " ctermfg=2"
exe "hi NvimTreeFileName guifg=" . color7 . " ctermfg=7"
exe "hi NvimTreeExecFile guifg=" . color2 . " ctermfg=2"
exe "hi NvimTreeSpecialFile guifg=" . color5 . " ctermfg=5"
exe "hi NvimTreeImageFile guifg=" . color5 . " ctermfg=5"
exe "hi NvimTreeMarkdownFile guifg=" . color1 . " ctermfg=1"
exe "hi NvimTreeIndentMarker guifg=" . color8 . " ctermfg=8"

" Neo-tree colors
exe "hi NeoTreeDirectoryName guifg=" . color4 . " ctermfg=4"
exe "hi NeoTreeDirectoryIcon guifg=" . color4 . " ctermfg=4"
exe "hi NeoTreeFileName guifg=" . color7 . " ctermfg=7"
exe "hi NeoTreeFileIcon guifg=" . color5 . " ctermfg=5"
exe "hi NeoTreeModified guifg=" . color3 . " ctermfg=3"
exe "hi NeoTreeGitAdded guifg=" . color2 . " ctermfg=2"
exe "hi NeoTreeGitDeleted guifg=" . color1 . " ctermfg=1"
exe "hi NeoTreeGitModified guifg=" . color3 . " ctermfg=3"
exe "hi NeoTreeGitUntracked guifg=" . color8 . " ctermfg=8"

" Telescope colors
exe "hi TelescopeSelection guifg=" . color7 . " guibg=" . color8 . " ctermfg=7 ctermbg=8"
exe "hi TelescopeSelectionCaret guifg=" . color1 . " ctermfg=1"
exe "hi TelescopeMultiSelection guifg=" . color2 . " ctermfg=2"
exe "hi TelescopeNormal guifg=" . color7 . " ctermfg=7"
exe "hi TelescopeBorder guifg=" . color8 . " ctermfg=8"
exe "hi TelescopePromptBorder guifg=" . color4 . " ctermfg=4"
exe "hi TelescopeResultsBorder guifg=" . color8 . " ctermfg=8"
exe "hi TelescopePreviewBorder guifg=" . color8 . " ctermfg=8"

" LSP and diagnostic colors
exe "hi DiagnosticError guifg=" . color1 . " ctermfg=1"
exe "hi DiagnosticWarn guifg=" . color3 . " ctermfg=3"
exe "hi DiagnosticInfo guifg=" . color4 . " ctermfg=4"
exe "hi DiagnosticHint guifg=" . color8 . " ctermfg=8"