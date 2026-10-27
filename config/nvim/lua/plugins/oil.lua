return {
  "stevearc/oil.nvim",
  lazy = false, -- must load early so it can replace netrw
  keys = {
    { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer" },
    { "-",         "<cmd>Oil<cr>", desc = "File explorer" },
  },
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = true },
    columns = {}, -- no icons, so no special font is needed
    keymaps = {
      -- free Ctrl-h / Ctrl-l so tmux-navigator keeps working inside oil
      ["<C-h>"] = false,
      ["<C-l>"] = false,
    },
  },
}
