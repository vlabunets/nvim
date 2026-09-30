-- Native statusline, ported from the former galaxyline.nvim config (by ecosse)
-- Git data comes from gitsigns, icons from nvim-web-devicons.

local M = {}

local lineLengthWarning = 80
local lineLengthError = 120
local leftbracket = "\u{E0B6}" -- Curve.
local rightbracket = "\u{E0B4}" -- Curve.

local short_line_list = { "snacks_layout_box", "vista", "dbui", "packer", "tagbar" }

-- Colours, maps and icons {{{1
local colors = {
  bg              = EcoVim.colorscheme == "nightfly" and "#011627" or "NONE",
  modetext        = "#000000",

  giticon         = "#FF8800",
  gitbg           = "#5C2C2E",
  gittext         = "#C5C5C5",

  diagerror       = "#F44747",
  diagwarn        = "#FF8800",
  diaghint        = "#4FC1FF",
  diaginfo        = "#FFCC66",

  lspicon         = "#68AF00",
  lspbg           = "#304B2E",
  lsptext         = "#C5C5C5",

  typeicon        = "#FF8800",
  typebg          = "#5C2C2E",
  typetext        = "#C5C5C5",

  statsicon       = "#9CDCFE",
  statsbg         = "#5080A0",
  statstext       = "#000000",

  linelongerrorfg = "#FF0000",
  linelongwarnfg  = "#FFFF00",

  shortbg         = "#DCDCAA",
  shorttext       = "#000000",
  shortrighttext  = "#7C4C4E",

  red             = "#D16969",
  green           = "#608B4E",
  blue            = "#569CD6",
}

local mode_map = {
  ["n"]      = { "#569CD6", "NORMAL" },
  ["i"]      = { "#D16969", "INSERT" },
  ["R"]      = { "#D16969", "REPLACE" },
  ["c"]      = { "#608B4E", "COMMAND" },
  ["v"]      = { "#C586C0", "VISUAL" },
  ["V"]      = { "#C586C0", "VIS-LN" },
  ["\22"]    = { "#C586C0", "VIS-BLK" },
  ["s"]      = { "#FF8800", "SELECT" },
  ["S"]      = { "#FF8800", "SEL-LN" },
  ["\19"]    = { "#DCDCAA", "SEL-BLK" },
  ["t"]      = { "#569CD6", "TERMINAL" },
  ["Rv"]     = { "#D16D69", "VIR-REP" },
  ["rm"]     = { "#FF0000", "- More -" },
  ["r"]      = { "#FF0000", "- Hit-Enter -" },
  ["r?"]     = { "#FF0000", "- Confirm -" },
  ["cv"]     = { "#569CD6", "Vim Ex Mode" },
  ["ce"]     = { "#569CD6", "Normal Ex Mode" },
  ["!"]      = { "#569CD6", "Shell Running" },
  ["ic"]     = { "#DCDCAA", "INSERT" },
  ["ix"]     = { "#DCDCAA", "INSERT" },
  ["no"]     = { "#DCDCAA", "O-PENDING" },
  ["nov"]    = { "#DCDCAA", "O-PENDING" },
  ["noV"]    = { "#DCDCAA", "O-PENDING" },
  ["no\22"]  = { "#DCDCAA", "O-PENDING" },
  ["niI"]    = { "#DCDCAA", "NORMAL" },
  ["niR"]    = { "#DCDCAA", "NORMAL" },
  ["niV"]    = { "#DCDCAA", "NORMAL" },
  ["Rc"]     = { "#DCDCAA", "REPLACE" },
  ["Rx"]     = { "#DCDCAA", "REPLACE" },
}

local icons = {
  vim  = "\u{E62B}",
  dos  = "\u{E70F}",
  unix = "\u{F17C}",
  mac  = "\u{F179}",
}
-- }}}1

-- Helpers {{{1
local function hl(name, fg, bg)
  vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
end

--- Wrap text in a highlight group
local function c(group, text)
  if text == nil or text == "" then return "" end
  return "%#" .. group .. "#" .. text
end

local function esc(s)
  return (tostring(s):gsub("%%", "%%%%"))
end

local function get_mode()
  local m = vim.api.nvim_get_mode().mode
  return mode_map[m] or mode_map[m:sub(1, 1)] or { "#569CD6", m }
end

local function hide_in_width()
  return vim.fn.winwidth(0) / 2 > 40
end

local function set_highlights()
  hl("SlGitStart", colors.giticon, colors.bg)
  hl("SlGitIcon", colors.gitbg, colors.giticon)
  hl("SlGitMid", colors.giticon, colors.gitbg)
  hl("SlGitBranch", colors.gittext, colors.gitbg)
  hl("SlDiffAdd", colors.green, colors.gitbg)
  hl("SlDiffMod", colors.blue, colors.gitbg)
  hl("SlDiffRemove", colors.red, colors.gitbg)
  hl("SlGitEnd", colors.gitbg, colors.bg)

  hl("SlLspStart", colors.lspicon, colors.bg)
  hl("SlLspIcon", colors.lspbg, colors.lspicon)
  hl("SlLspMid", colors.lspicon, colors.lspbg)
  hl("SlLspText", colors.lsptext, colors.lspbg)
  hl("SlDiagError", colors.diagerror, colors.lspbg)
  hl("SlDiagWarn", colors.diagwarn, colors.lspbg)
  hl("SlDiagHint", colors.diaghint, colors.lspbg)
  hl("SlDiagInfo", colors.diaginfo, colors.lspbg)
  hl("SlLspEnd", colors.lspbg, colors.bg)

  hl("SlTypeStart", colors.typeicon, colors.bg)
  hl("SlTypeIcon", colors.typebg, colors.typeicon)
  hl("SlTypeMid", colors.typeicon, colors.typebg)
  hl("SlTypeText", colors.typetext, colors.typebg)
  hl("SlTypeEnd", colors.typebg, colors.bg)

  hl("SlStatsStart", colors.statsicon, colors.bg)
  hl("SlStatsIcon", colors.statsbg, colors.statsicon)
  hl("SlStatsMid", colors.statsicon, colors.statsbg)
  hl("SlStatsText", colors.statstext, colors.statsbg)
  hl("SlStatsEnd", colors.statsbg, colors.bg)

  hl("SlShortEdge", colors.shortbg, colors.bg)
  hl("SlShortText", colors.shorttext, colors.shortbg)
  hl("SlShortRight", colors.shortrighttext, colors.bg)
  hl("SlBg", nil, colors.bg)
end

-- Rag status function
local function set_line_width_colours()
  local colbg = colors.statsbg
  local linebg = colors.statsbg
  local col = vim.fn.col(".")
  local width = vim.fn.strwidth(vim.fn.getline("."))

  if col > lineLengthError then
    colbg = colors.linelongerrorfg
  elseif col > lineLengthWarning then
    colbg = colors.linelongwarnfg
  end

  if width > lineLengthError then
    linebg = colors.linelongerrorfg
  elseif width > lineLengthWarning then
    linebg = colors.linelongwarnfg
  end

  hl("SlLinePosStart", colbg, colors.statsbg)
  hl("SlLinePosColNum", colors.statstext, colbg)
  hl("SlLinePosMid", linebg, colbg)
  hl("SlLineLenNum", colors.statstext, linebg)
  hl("SlLinePosEnd", linebg, colors.statsbg)
end

local function file_icon()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then return "" end
  local name = vim.fn.expand("%:t")
  local icon = devicons.get_icon(name, vim.fn.expand("%:e"), { default = true })
  return icon and (icon .. " ") or ""
end

local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand("%:p"))
  if size <= 0 then return "" end
  if size < 1024 then
    return size .. "b "
  elseif size < 1024 * 1024 then
    return string.format("%.1fk ", size / 1024)
  elseif size < 1024 * 1024 * 1024 then
    return string.format("%.1fm ", size / 1024 / 1024)
  end
  return string.format("%.1fg ", size / 1024 / 1024 / 1024)
end

local function line_percent()
  local current, total = vim.fn.line("."), vim.fn.line("$")
  if current == 1 then
    return " Top "
  elseif current == total then
    return " Bot "
  end
  return " " .. math.floor(current / total * 100) .. "% "
end
-- }}}1

-- Sections {{{1
local function mode_section()
  local mode = get_mode()
  hl("SlViModeEdge", mode[1], colors.bg)
  hl("SlViMode", colors.modetext, mode[1])
  return c("SlBg", " ")
    .. c("SlViModeEdge", leftbracket)
    .. c("SlViMode", icons.vim .. " " .. mode[2])
    .. c("SlViModeEdge", rightbracket .. " ")
end

local function git_section()
  local head = vim.b.gitsigns_head
  if vim.bo.buftype == "terminal" or head == nil or head == "" then return "" end

  local out = c("SlGitStart", leftbracket)
    .. c("SlGitIcon", "\u{E725} ")
    .. c("SlGitMid", rightbracket .. " ")
    .. c("SlGitBranch", esc(head) .. " ")

  local status = vim.b.gitsigns_status_dict or {}
  if (status.added or 0) > 0 then out = out .. c("SlDiffAdd", " \u{F0FE} " .. status.added .. " ") end
  if (status.changed or 0) > 0 then out = out .. c("SlDiffMod", " \u{F14B} " .. status.changed .. " ") end
  if (status.removed or 0) > 0 then out = out .. c("SlDiffRemove", " \u{F146} " .. status.removed .. " ") end

  return out .. c("SlGitEnd", rightbracket .. " ")
end

local function lsp_section()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local name = #clients > 0 and clients[1].name or "No Active Lsp"
  -- Prefer the language server for this filetype over linters and generic ones (copilot, typos, ...)
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, vim.bo.filetype)
      and client:supports_method("textDocument/definition") then
      name = client.name
      break
    end
  end

  local out = c("SlLspStart", leftbracket)
    .. c("SlLspIcon", "\u{F085}")
    .. c("SlLspMid", rightbracket .. " ")
    .. c("SlLspText", esc(name) .. " ")

  if #clients > 0 then
    local s = vim.diagnostic.severity
    local diags = {
      { s.ERROR, "SlDiagError", EcoVim.icons.errorOutline },
      { s.WARN, "SlDiagWarn", " \u{F529} " },
      { s.HINT, "SlDiagHint", EcoVim.icons.lightbulbOutline },
      { s.INFO, "SlDiagInfo", EcoVim.icons.infoOutline },
    }
    for _, d in ipairs(diags) do
      local count = #vim.diagnostic.get(0, { severity = d[1] })
      if count > 0 then out = out .. c(d[2], d[3] .. count .. " ") end
    end
  end

  return out .. c("SlLspEnd", rightbracket .. " ")
end

local function package_info_section()
  local ok, package = pcall(require, "package-info")
  if not ok then return "" end
  local status = package.get_status()
  if status == nil or status == "" then return "" end
  return c("SlBg", esc(status) .. " ")
end

local function type_section()
  local out = c("SlTypeStart", leftbracket)
    .. c("SlTypeIcon", " " .. (icons[vim.bo.fileformat] or ""))
    .. c("SlTypeMid", rightbracket .. " ")

  if EcoVim.statusline.path_enabled and #vim.fn.expand("%:p") > 0 then
    local fname = EcoVim.statusline.path == "relative" and vim.fn.expand("%:.") or vim.fn.expand("%:t")
    out = out .. c("SlTypeText", esc(fname) .. " ")
  end

  local size = file_size()
  out = out .. c("SlTypeMid", file_icon())
    .. c("SlTypeText", vim.bo.filetype:upper())
    .. (size ~= "" and (c("SlTypeMid", " \u{F0C7} ") .. c("SlTypeText", size)) or "")

  local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
  out = out .. c("SlTypeMid", "\u{F031}") .. c("SlTypeText", " " .. enc:upper())

  return out .. c("SlTypeEnd", rightbracket) .. c("SlBg", " ")
end

local function stats_section()
  set_line_width_colours()

  local out = c("SlStatsStart", leftbracket)
    .. c("SlStatsIcon", "\u{2151}")
    .. c("SlStatsMid", rightbracket .. " ")
    .. c("SlStatsText", line_percent())
    .. c("SlStatsMid", "\u{F07D}")
    .. c("SlStatsText", string.format(" %s /%4i ", vim.fn.line("."), vim.fn.line("$")))
    .. c("SlStatsMid", "\u{F07E} ")
    .. c("SlLinePosStart", leftbracket)
    .. c("SlLinePosColNum", string.format("%3i", vim.fn.col(".")) .. " /")
    .. c("SlLinePosMid", " " .. leftbracket)
    .. c("SlLineLenNum", " " .. string.format("%3i", #vim.fn.getline(".")))
    .. c("SlLinePosEnd", " " .. rightbracket .. " ")

  if hide_in_width() then
    out = out .. c("SlStatsMid", vim.bo.expandtab and " \u{F012E} " or " \u{F0131} ")
      .. c("SlStatsText", tostring(vim.bo.shiftwidth))
  end

  return out .. c("SlStatsEnd", rightbracket .. " ")
end

local function short_line()
  local out = c("SlShortEdge", leftbracket)
    .. c("SlShortText", " " .. vim.bo.filetype:upper() .. " ")
  local name = vim.fn.expand("%:t")
  if name ~= "" then out = out .. c("SlShortText", esc(name)) end
  return out .. c("SlShortEdge", rightbracket) .. c("SlBg", "%=") .. c("SlShortRight", file_icon())
end
-- }}}1

function M.render()
  local ok, result = pcall(function()
    if vim.tbl_contains(short_line_list, vim.bo.filetype) then
      return short_line()
    end
    return mode_section()
      .. git_section()
      .. lsp_section()
      .. c("SlBg", "%=")
      .. package_info_section()
      .. type_section()
      .. stats_section()
  end)
  return ok and result or ("statusline error: " .. esc(result))
end

function M.setup()
  set_highlights()

  local group = vim.api.nvim_create_augroup("EcoVimStatusline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = set_highlights })
  vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
    group = group,
    callback = function() vim.cmd.redrawstatus() end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "GitSignsUpdate", "GitSignsChanged" },
    callback = function() vim.cmd.redrawstatus() end,
  })

  vim.o.statusline = "%!v:lua.require'internal.statusline'.render()"
end

return M
