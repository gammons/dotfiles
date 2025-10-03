-- Neo-tree configuration to match NERDTree keybindings
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        -- NERDTree-style mappings
        ["o"] = "open",           -- open files and toggle directories
        ["<cr>"] = "open",        -- also keep Enter working
        ["s"] = "open_split",     -- open in horizontal split
        ["v"] = "open_vsplit",    -- open in vertical split
        ["t"] = "open_tabnew",    -- open in new tab
        ["<C-p>"] = "prev_source",
        ["<C-n>"] = "next_source",
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      use_libuv_file_watcher = true,
    },
  },
}
