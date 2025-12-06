-- Synthwave 2077 Theme for Neovim
-- Hand-ported from the VS Code theme

if vim.g.colors_name then
  vim.cmd('hi clear')
end

if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'synthwave'

-- Palette extracted from Synthwave 2077
local c = {
  bg = "#101116",
  fg = "#00d4b1",
  comment = "#6766b3",
  string = "#fd7fd9",
  keyword = "#ffe0e0",
  func = "#EEFFFF",
  var = "#62d4b7",
  type = "#00FF9C",
  const = "#fffd91",
  operator = "#EEFFFF",
  tag = "#ffe0e0",
  selection = "#311b92",
  line_nr = "#00d4b1",
  cursor_line = "#24005e",
  error = "#ff0000",
  warning = "#e5ff00",
  green = "#00ff9c",
  yellow = "#fffd91",
  cyan = "#08e1d7",
  magenta = "#e215d4",
  attrib = "#ee6dff"
}

local h = function(group, opts)
  opts.bg = opts.bg or "NONE"
  opts.fg = opts.fg or "NONE"
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base
h("Normal", { fg = c.fg, bg = c.bg })
h("SignColumn", { bg = c.bg })
h("EndOfBuffer", { fg = c.bg })

-- UI
h("Cursor", { fg = c.bg, bg = c.fg })
h("CursorLine", { bg = c.cursor_line })
h("CursorLineNr", { fg = c.const, bold = true })
h("LineNr", { fg = c.line_nr })
h("Visual", { bg = c.selection })
h("Pmenu", { bg = "#001420", fg = c.fg })
h("PmenuSel", { bg = "#003622", fg = c.fg })
h("NormalFloat", { bg = "#001420", fg = c.fg })
h("FloatBorder", { fg = c.type, bg = "#001420" })

-- Syntax
h("Comment", { fg = c.comment, italic = true })
h("String", { fg = c.string })
h("Number", { fg = c.const })
h("Boolean", { fg = c.const })
h("Float", { fg = c.const })
h("Identifier", { fg = c.var })
h("Function", { fg = c.func, bold = true })
h("Statement", { fg = c.keyword, bold = true })
h("Keyword", { fg = c.keyword, bold = true })
h("Conditional", { fg = c.keyword, bold = true })
h("Repeat", { fg = c.keyword, bold = true })
h("Label", { fg = c.keyword, bold = true })
h("Operator", { fg = c.operator })
h("Type", { fg = c.type, bold = true })
h("StorageClass", { fg = c.type, bold = true })
h("Structure", { fg = c.type, bold = true })
h("Typedef", { fg = c.type, bold = true })
h("PreProc", { fg = c.keyword })
h("Include", { fg = c.keyword })
h("Define", { fg = c.keyword })
h("Macro", { fg = c.keyword })
h("Special", { fg = c.func })
h("SpecialChar", { fg = c.const })
h("Delimiter", { fg = c.fg })
h("Error", { fg = c.error })
h("Todo", { fg = c.warning, bold = true })

-- Treesitter
h("@variable", { fg = c.var })
h("@function", { fg = c.func, bold = true })
h("@keyword", { fg = c.keyword, bold = true })
h("@string", { fg = c.string })
h("@comment", { fg = c.comment, italic = true })
h("@type", { fg = c.type, bold = true })
h("@constant", { fg = c.const, bold = true })
h("@constructor", { fg = c.type, bold = true })
h("@field", { fg = c.var })
h("@property", { fg = c.var })
h("@parameter", { fg = c.const, bold = true })
h("@tag", { fg = c.tag })
h("@tag.attribute", { fg = c.attrib })
h("@tag.delimiter", { fg = c.fg })

-- Plugins
h("GitSignsAdd", { fg = c.green })
h("GitSignsChange", { fg = c.yellow })
h("GitSignsDelete", { fg = c.error })
h("TelescopeBorder", { fg = c.type })
h("TelescopePromptBorder", { fg = c.type })
h("TelescopeResultsBorder", { fg = c.type })
h("NeoTreeNormal", { bg = "#0c0c11", fg = c.fg })
h("NeoTreeNormalNC", { bg = "#0c0c11", fg = c.fg })
