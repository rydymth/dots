-- Connections come from environment variables (set in ~/.config/zsh/env/99-secrets.zsh),
-- so no passwords live in this config. Unset or empty variables are skipped.
local connections = {
  { name = "podman (local)",      env = "DB_PODMAN_URL" },
  { name = "lan (office server)", env = "DB_LAN_URL" },
  { name = "digitalocean",        env = "DB_DO_URL" },
}

return {
  { "tpope/vim-dadbod", cmd = "DB" },
  { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = { { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Database UI" } },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 0
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod"

      local dbs = {}
      for _, c in ipairs(connections) do
        local url = vim.env[c.env]
        if url and url ~= "" then
          table.insert(dbs, { name = c.name, url = url })
        end
      end
      vim.g.dbs = dbs
    end,
  },
}
