local map = vim.keymap.set

-- ── basics ─────────────────────────────────────────────
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all (discard)" })

-- ── movement that keeps the cursor centred ─────────────
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- move wrapped lines as they look on screen
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- ── editing ────────────────────────────────────────────
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("x", "<leader>p", [["_dP]], { desc = "Paste without losing the register" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })

-- ── buffers ────────────────────────────────────────────
-- NOTE: H, L and D replace Vim's built-ins (screen top/bottom, delete to end of line).
-- Delete to end of line is still available as d$
map("n", "H", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "D", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ── splits (moving between them is Ctrl-h/j/k/l via tmux-navigator)
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>s=", "<C-w>=", { desc = "Equalise splits" })

-- ── diagnostics ────────────────────────────────────────
map("n", "gl", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

-- ── terminal ───────────────────────────────────────────
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
