return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- provides the "roslyn" package
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "roslyn", "netcoredbg", "lua-language-server" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {}, -- auto-enables servers that Mason has installed
  },
  { "seblyng/roslyn.nvim", commit = "f2ec6ee6384c3b611ddc817b9e78b20cd0334bbb", ft = "cs", opts = {} }, -- C# language server

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.diagnostic.config({ virtual_text = true, severity_sort = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
          -- built in on 0.11: K hover, grn rename, gra code action, grr references
        end,
      })
    end,
  },
}
