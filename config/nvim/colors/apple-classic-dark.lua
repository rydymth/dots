-- ==============================================================================
-- Apple Classic Pastel Dark Theme for Neovim
-- Matching labwc, yazi, and Quickshell QtObject color scheme
-- ==============================================================================

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "apple-classic-dark"

local c = {
  bg                  = "#2c2b2b",
  bg_dark             = "#222121",
  surface             = "#373b41",
  surface_high        = "#424040",

  fg                  = "#c5c8c6",
  fg_heading          = "#f0c674",
  fg_muted            = "#969896",

  blue                = "#81a2be",
  cyan                = "#8abeb7",
  purple              = "#b294bb",
  green               = "#b5bd68",
  yellow              = "#f0c674",
  red                 = "#cc6666",
  orange              = "#de935f",

  selection           = "#373b41",
  comment             = "#707880",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor Base UI
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg_dark })
hl("FloatBorder", { fg = c.blue, bg = c.bg_dark })
hl("ColorColumn", { bg = c.bg_dark })
hl("Cursor", { fg = c.bg, bg = c.fg })
hl("CursorLine", { bg = c.bg_dark })
hl("CursorColumn", { bg = c.bg_dark })
hl("LineNr", { fg = c.comment })
hl("CursorLineNr", { fg = c.cyan, bold = true })
hl("VertSplit", { fg = c.surface_high })
hl("WinSeparator", { fg = c.surface_high })

-- Visual Selection & Search
hl("Visual", { bg = c.selection, bold = true })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.cyan })

-- Pmenu (Completion Menu)
hl("Pmenu", { fg = c.fg, bg = c.bg_dark })
hl("PmenuSel", { fg = c.bg, bg = c.blue, bold = true })
hl("PmenuSbar", { bg = c.surface })
hl("PmenuThumb", { bg = c.blue })

-- Statusline / Tabline
hl("StatusLine", { fg = c.fg_heading, bg = c.surface })
hl("StatusLineNC", { fg = c.fg_muted, bg = c.bg_dark })
hl("TabLine", { fg = c.fg_muted, bg = c.bg_dark })
hl("TabLineSel", { fg = c.cyan, bg = c.surface, bold = true })
hl("TabLineFill", { bg = c.bg_dark })

-- Syntax Highlighting
hl("Comment", { fg = c.comment, italic = true })
hl("Constant", { fg = c.orange })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.orange })
hl("Boolean", { fg = c.orange })
hl("Float", { fg = c.orange })

hl("Identifier", { fg = c.cyan })
hl("Function", { fg = c.blue, bold = true })

hl("Statement", { fg = c.purple, bold = true })
hl("Conditional", { fg = c.purple, bold = true })
hl("Repeat", { fg = c.purple, bold = true })
hl("Label", { fg = c.purple })
hl("Operator", { fg = c.fg_heading })
hl("Keyword", { fg = c.purple, bold = true })
hl("Exception", { fg = c.red, bold = true })

hl("PreProc", { fg = c.cyan })
hl("Include", { fg = c.blue })
hl("Define", { fg = c.purple })
hl("Macro", { fg = c.cyan })

hl("Type", { fg = c.yellow, bold = true })
hl("StorageClass", { fg = c.yellow })
hl("Structure", { fg = c.yellow })
hl("Typedef", { fg = c.yellow })

hl("Special", { fg = c.blue })
hl("SpecialChar", { fg = c.orange })
hl("Tag", { fg = c.purple })
hl("Delimiter", { fg = c.fg_heading })
hl("Debug", { fg = c.red })

hl("Underlined", { underline = true })
hl("Error", { fg = c.red, bold = true })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- Diagnostics (LSP)
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.cyan })
hl("DiagnosticHint", { fg = c.green })

hl("DiagnosticUnderlineError", { underline = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { underline = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { underline = true, sp = c.cyan })
hl("DiagnosticUnderlineHint", { underline = true, sp = c.green })

-- Git Signs / Diff
hl("DiffAdd", { fg = c.green, bg = c.bg_dark })
hl("DiffChange", { fg = c.yellow, bg = c.bg_dark })
hl("DiffDelete", { fg = c.red, bg = c.bg_dark })
hl("DiffText", { fg = c.blue, bg = c.surface })

-- ------------------------------------------------------------------------------
-- Additions (not in the original palette file; reuse the same colors)
-- ------------------------------------------------------------------------------

-- Base UI that otherwise falls back to defaults
hl("SignColumn", { fg = c.comment, bg = c.bg })
hl("EndOfBuffer", { fg = c.bg })
hl("NonText", { fg = c.surface_high })
hl("Whitespace", { fg = c.surface_high })
hl("MatchParen", { fg = c.orange, bold = true, underline = true })
hl("Folded", { fg = c.fg_muted, bg = c.bg_dark })
hl("FoldColumn", { fg = c.comment, bg = c.bg })
hl("Directory", { fg = c.blue })
hl("Title", { fg = c.fg_heading, bold = true })
hl("FloatTitle", { fg = c.fg_heading, bg = c.bg_dark, bold = true })
hl("WinBar", { fg = c.fg, bg = c.bg })
hl("WinBarNC", { fg = c.fg_muted, bg = c.bg })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.yellow })
hl("MoreMsg", { fg = c.green })
hl("Question", { fg = c.cyan })
hl("ModeMsg", { fg = c.fg_heading })
hl("WildMenu", { fg = c.bg, bg = c.blue })
hl("SpellBad", { underline = true, sp = c.red })
hl("SpellCap", { underline = true, sp = c.yellow })

-- Diagnostics virtual text and floating windows
hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.bg_dark })
hl("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.bg_dark })
hl("DiagnosticVirtualTextInfo", { fg = c.cyan, bg = c.bg_dark })
hl("DiagnosticVirtualTextHint", { fg = c.green, bg = c.bg_dark })

-- Debugger (nvim-dap)
hl("DapBreakpoint", { fg = c.red })
hl("DapBreakpointCondition", { fg = c.yellow })
hl("DapStopped", { fg = c.green })
hl("DapStoppedLine", { bg = c.surface })

-- Completion menu (nvim-cmp)
hl("CmpItemAbbr", { fg = c.fg })
hl("CmpItemAbbrMatch", { fg = c.blue, bold = true })
hl("CmpItemAbbrMatchFuzzy", { fg = c.blue, bold = true })
hl("CmpItemAbbrDeprecated", { fg = c.comment, strikethrough = true })
hl("CmpItemMenu", { fg = c.fg_muted })
hl("CmpItemKind", { fg = c.purple })

-- File explorer (oil.nvim)
hl("OilDir", { fg = c.blue, bold = true })
hl("OilDirIcon", { fg = c.blue })
hl("OilLink", { fg = c.cyan })
hl("OilFile", { fg = c.fg })

-- Picker (fzf-lua)
hl("FzfLuaNormal", { fg = c.fg, bg = c.bg_dark })
hl("FzfLuaBorder", { fg = c.blue, bg = c.bg_dark })
hl("FzfLuaTitle", { fg = c.fg_heading, bg = c.bg_dark, bold = true })
hl("FzfLuaCursorLine", { bg = c.surface })

-- which-key
hl("WhichKey", { fg = c.cyan })
hl("WhichKeyGroup", { fg = c.blue })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeparator", { fg = c.comment })
