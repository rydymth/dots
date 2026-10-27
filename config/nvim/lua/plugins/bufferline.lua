-- Open buffers as a tab bar. Selected buffer: bright text, blue underline.
-- H / L (keymaps.lua) already cycle through them; D closes the current one.
local c = {
  bg = "#2c2b2b", bg_dark = "#222121", surface = "#373b41",
  fg = "#c5c8c6", muted = "#969896", comment = "#707880",
  blue = "#81a2be", cyan = "#8abeb7", yellow = "#f0c674", red = "#cc6666", orange = "#de935f",
}

local function bar(fg, bg, extra)
  return vim.tbl_extend("force", { fg = fg, bg = bg }, extra or {})
end

return {
  "akinsho/bufferline.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Buffer 1" },
    { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Buffer 2" },
    { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Buffer 3" },
    { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Buffer 4" },
    { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Buffer 5" },
    { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Buffer 6" },
    { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Buffer 7" },
    { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Buffer 8" },
    { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Buffer 9" },
    { "<leader>P", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
    { "<leader>O", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    { "<leader>pb", "<cmd>BufferLinePick<cr>", desc = "Pick buffer by letter" },
    { "<A-,>", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
    { "<A-.>", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
  },
  -- the underline indicator draws under the whole selected tab; make it blue
  -- (it would otherwise inherit the tab background and be invisible)
  config = function(_, opts)
    for name, hl in pairs(opts.highlights) do
      if name:match("_selected$") then
        hl.sp = c.blue
        hl.underline = true
      end
    end
    require("bufferline").setup(opts)
  end,
  opts = {
    options = {
      mode = "buffers",
      numbers = "ordinal",               -- the number <leader>N jumps to
      indicator = { style = "underline" },
      buffer_close_icon = "x",
      close_icon = "x",
      modified_icon = "+",
      left_trunc_marker = "<",
      right_trunc_marker = ">",
      separator_style = "thin",
      show_buffer_icons = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      themable = true,
      -- oil and other special buffers stay out of the bar
      custom_filter = function(buf)
        local ft = vim.bo[buf].filetype
        return ft ~= "oil" and ft ~= "dbui" and ft ~= "qf"
      end,
    },
    highlights = {
      fill                       = bar(c.comment, c.bg_dark),
      background                 = bar(c.muted, c.bg_dark),
      buffer_visible             = bar(c.muted, c.bg_dark),
      buffer_selected            = bar(c.fg, c.surface, { bold = true, italic = false }),
      numbers                    = bar(c.comment, c.bg_dark),
      numbers_visible            = bar(c.comment, c.bg_dark),
      numbers_selected           = bar(c.yellow, c.surface, { bold = true, italic = false }),
      modified                   = bar(c.orange, c.bg_dark),
      modified_visible           = bar(c.orange, c.bg_dark),
      modified_selected          = bar(c.orange, c.surface),
      separator                  = bar(c.bg, c.bg_dark),
      separator_visible          = bar(c.bg, c.bg_dark),
      separator_selected         = bar(c.bg, c.surface),
      indicator_visible          = bar(c.bg_dark, c.bg_dark),
      indicator_selected         = bar(c.blue, c.surface, { sp = c.blue, underline = true }),
      diagnostic                 = bar(c.comment, c.bg_dark),
      diagnostic_selected        = bar(c.fg, c.surface),
      error                      = bar(c.red, c.bg_dark),
      error_selected             = bar(c.red, c.surface, { bold = true }),
      error_diagnostic           = bar(c.red, c.bg_dark),
      error_diagnostic_selected  = bar(c.red, c.surface),
      warning                    = bar(c.yellow, c.bg_dark),
      warning_selected           = bar(c.yellow, c.surface, { bold = true }),
      warning_diagnostic         = bar(c.yellow, c.bg_dark),
      warning_diagnostic_selected = bar(c.yellow, c.surface),
      duplicate                  = bar(c.comment, c.bg_dark, { italic = false }),
      duplicate_visible          = bar(c.comment, c.bg_dark, { italic = false }),
      duplicate_selected         = bar(c.muted, c.surface, { italic = false }),
      pick                       = bar(c.red, c.bg_dark, { bold = true }),
      pick_visible               = bar(c.red, c.bg_dark, { bold = true }),
      pick_selected              = bar(c.red, c.surface, { bold = true }),
      close_button               = bar(c.comment, c.bg_dark),
      close_button_visible       = bar(c.comment, c.bg_dark),
      close_button_selected      = bar(c.fg, c.surface),
      tab                        = bar(c.muted, c.bg_dark),
      tab_selected               = bar(c.cyan, c.surface, { bold = true }),
      tab_separator              = bar(c.bg, c.bg_dark),
      tab_separator_selected     = bar(c.bg, c.surface),
    },
  },
}
