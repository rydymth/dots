return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "c_sharp", "sql", "lua", "json", "yaml", "bash",
        "markdown", "html", "typescript", "scss",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
