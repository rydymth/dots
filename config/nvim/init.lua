vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.lazy")

-- theme lives in ~/.config/nvim/colors/apple-classic-dark.lua
pcall(vim.cmd.colorscheme, "apple-classic-dark")
