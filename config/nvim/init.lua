vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")

-- `theme <name>` in the shell writes the choice to $XDG_STATE_HOME/theme/current.
-- Colorscheme files: colors/apple-classic-dark.lua, powershell-light.lua, sequoia-light.lua
local name = require("theme").current() or "apple-classic-dark"
if not pcall(vim.cmd.colorscheme, name) then
  pcall(vim.cmd.colorscheme, "apple-classic-dark")
end
