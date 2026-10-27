return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    icons = { mappings = false }, -- no Nerd Font required
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>d", group = "debug" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "split / window" },
    },
  },
  keys = {
    { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
  },
}
