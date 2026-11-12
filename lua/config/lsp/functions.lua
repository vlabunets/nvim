local M = {}

local FORMAT_ON_SAVE_GROUP = "format_on_save"

-- The single formatting entry point: <leader>cf, <C-s> and format-on-save all call it.
-- conform's default_format_opts (plugins/formatting.lua) already fall back to the LSP formatter.
function M.format()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ bufnr = 0 })
  else
    vim.lsp.buf.format({ bufnr = 0 })
  end
end

local function create_format_on_save()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup(FORMAT_ON_SAVE_GROUP, { clear = true }),
    callback = M.format,
  })
end

function M.enable_format_on_save()
  create_format_on_save()
  vim.notify("Enabled format on save", vim.log.levels.INFO, { title = "LSP" })
end

function M.disable_format_on_save()
  vim.api.nvim_del_augroup_by_name(FORMAT_ON_SAVE_GROUP)
  vim.notify("Disabled format on save", vim.log.levels.INFO, { title = "LSP" })
end

function M.toggle_format_on_save()
  if vim.fn.exists("#" .. FORMAT_ON_SAVE_GROUP .. "#BufWritePre") == 0 then
    M.enable_format_on_save()
  else
    M.disable_format_on_save()
  end
end

vim.api.nvim_create_user_command("LspToggleAutoFormat", M.toggle_format_on_save, {})

-- Enable format on save at startup if configured (silently)
if Nvim.lsp.format_on_save then
  create_format_on_save()
end

return M
