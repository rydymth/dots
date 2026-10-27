return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  opts = {
    defaults = { file_icons = false, git_icons = false },
    fzf_colors = true,
  },
  keys = {
    { "<leader>ff", function() require("fzf-lua").files() end,                  desc = "Find files" },
    { "<leader>fg", function() require("fzf-lua").live_grep() end,              desc = "Grep in project" },
    { "<leader>fw", function() require("fzf-lua").grep_cword() end,             desc = "Grep word under cursor" },
    { "<leader>fb", function() require("fzf-lua").buffers() end,                desc = "Buffers" },
    { "<leader>fr", function() require("fzf-lua").oldfiles() end,               desc = "Recent files" },
    { "<leader>fh", function() require("fzf-lua").helptags() end,               desc = "Help" },
    { "<leader>fk", function() require("fzf-lua").keymaps() end,                desc = "Keymaps" },
    { "<leader>fd", function() require("fzf-lua").diagnostics_workspace() end,  desc = "Diagnostics" },
    { "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end,   desc = "Symbols in file" },
    { "<leader>fS", function() require("fzf-lua").lsp_live_workspace_symbols() end, desc = "Symbols in project" },
    { "<leader>/",  function() require("fzf-lua").blines() end,                 desc = "Search in buffer" },
  },
}
