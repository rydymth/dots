-- Shared highlight definitions for the light colorschemes (powershell-light, sequoia-light).
-- Palettes come from lua/theme/palettes.lua, which tools/build.py generates.
-- The dark theme keeps its own file: colors/apple-classic-dark.lua.
local M = {}

M.palettes = require("theme.palettes")

--- name of the theme chosen with the `theme` command (state file), or nil
function M.current()
  local state = vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")
  local f = io.open(state .. "/theme/current", "r")
  if not f then return nil end
  local name = f:read("*l")
  f:close()
  return name and name:match("^%s*(%S+)%s*$") or nil
end

--- palette of the active colorscheme (falls back to the dark one)
function M.active()
  return M.palettes[vim.g.colors_name or ""] or M.palettes["apple-classic-dark"]
end

function M.apply(name)
  local p = M.palettes[name]
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.o.background = p.kind
  vim.g.colors_name = name

  local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end
  local c = p

  -- Editor base UI
  hl("Normal", { fg = c.fg, bg = c.bg })
  hl("NormalFloat", { fg = c.fg, bg = c.bg_dark })
  hl("FloatBorder", { fg = c.accent, bg = c.bg_dark })
  hl("ColorColumn", { bg = c.bg_dark })
  hl("Cursor", { fg = c.bg, bg = c.fg })
  hl("CursorLine", { bg = c.bg_dark })
  hl("CursorColumn", { bg = c.bg_dark })
  hl("LineNr", { fg = c.comment })
  hl("CursorLineNr", { fg = c.accent, bold = true })
  hl("VertSplit", { fg = c.surface_high })
  hl("WinSeparator", { fg = c.surface_high })

  -- Visual selection and search
  hl("Visual", { bg = c.selection })
  hl("Search", { fg = c.search_fg, bg = c.search_hl_bg })
  hl("CurSearch", { fg = c.search_fg, bg = c.search_bg, bold = true })
  hl("IncSearch", { fg = c.search_fg, bg = c.search_bg, bold = true })

  -- Completion menu
  hl("Pmenu", { fg = c.fg, bg = c.bg_dark })
  hl("PmenuSel", { fg = c.on_accent, bg = c.accent, bold = true })
  hl("PmenuSbar", { bg = c.surface })
  hl("PmenuThumb", { bg = c.accent })

  -- Statusline / tabline
  hl("StatusLine", { fg = c.fg_heading, bg = c.surface })
  hl("StatusLineNC", { fg = c.fg_muted, bg = c.bg_dark })
  hl("TabLine", { fg = c.fg_muted, bg = c.bg_dark })
  hl("TabLineSel", { fg = c.accent, bg = c.surface, bold = true })
  hl("TabLineFill", { bg = c.bg_dark })

  -- Syntax
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
  hl("Operator", { fg = c.fg_muted })
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
  hl("Delimiter", { fg = c.fg_muted })
  hl("Debug", { fg = c.red })
  hl("Underlined", { underline = true })
  hl("Error", { fg = c.red, bold = true })
  hl("Todo", { fg = c.on_accent, bg = c.yellow, bold = true })

  -- Diagnostics
  hl("DiagnosticError", { fg = c.red })
  hl("DiagnosticWarn", { fg = c.yellow })
  hl("DiagnosticInfo", { fg = c.cyan })
  hl("DiagnosticHint", { fg = c.green })
  hl("DiagnosticUnderlineError", { underline = true, sp = c.red })
  hl("DiagnosticUnderlineWarn", { underline = true, sp = c.yellow })
  hl("DiagnosticUnderlineInfo", { underline = true, sp = c.cyan })
  hl("DiagnosticUnderlineHint", { underline = true, sp = c.green })
  hl("DiagnosticVirtualTextError", { fg = c.red, bg = c.bg_dark })
  hl("DiagnosticVirtualTextWarn", { fg = c.yellow, bg = c.bg_dark })
  hl("DiagnosticVirtualTextInfo", { fg = c.cyan, bg = c.bg_dark })
  hl("DiagnosticVirtualTextHint", { fg = c.green, bg = c.bg_dark })

  -- Diff / git
  hl("DiffAdd", { fg = c.green, bg = c.bg_dark })
  hl("DiffChange", { fg = c.yellow, bg = c.bg_dark })
  hl("DiffDelete", { fg = c.red, bg = c.bg_dark })
  hl("DiffText", { fg = c.blue, bg = c.surface })

  -- Misc base UI
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
  hl("WildMenu", { fg = c.on_accent, bg = c.accent })
  hl("SpellBad", { underline = true, sp = c.red })
  hl("SpellCap", { underline = true, sp = c.yellow })

  -- Debugger (nvim-dap)
  hl("DapBreakpoint", { fg = c.red })
  hl("DapBreakpointCondition", { fg = c.yellow })
  hl("DapStopped", { fg = c.green })
  hl("DapStoppedLine", { bg = c.surface })

  -- Completion (nvim-cmp)
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
  hl("FzfLuaBorder", { fg = c.accent, bg = c.bg_dark })
  hl("FzfLuaTitle", { fg = c.fg_heading, bg = c.bg_dark, bold = true })
  hl("FzfLuaCursorLine", { bg = c.surface })

  -- which-key
  hl("WhichKey", { fg = c.cyan })
  hl("WhichKeyGroup", { fg = c.blue })
  hl("WhichKeyDesc", { fg = c.fg })
  hl("WhichKeySeparator", { fg = c.comment })
end

return M
