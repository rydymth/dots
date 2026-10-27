local o = vim.opt

o.number = true
o.relativenumber = true
o.cursorline = false -- no highlighted current line
o.signcolumn = "yes" -- stops text shifting when diagnostics appear
o.scrolloff = 8
o.wrap = false

o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true

o.undofile = true -- undo survives closing the file
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400
o.termguicolors = true
o.showmode = false
