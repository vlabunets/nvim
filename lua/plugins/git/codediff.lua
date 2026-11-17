local M = {}

-- Tabs that hold a codediff view, tracked through codediff's public CodeDiffOpen/CodeDiffClose
-- events (its session modules are internal API).
local open_tabs = {}

function M.track_tabs()
  local group = vim.api.nvim_create_augroup("nvim_codediff_tabs", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffOpen",
    callback = function(args)
      open_tabs[(args.data or {}).tabpage or vim.api.nvim_get_current_tabpage()] = true
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CodeDiffClose",
    callback = function(args)
      open_tabs[(args.data or {}).tabpage or -1] = nil
    end,
  })
end

--- Close the codediff view in the current tab, or open `:CodeDiff {args}`.
--- Mirrors the old diffview toggles: the same key opens and closes.
---@param args? string
function M.toggle(args)
  local tab = vim.api.nvim_get_current_tabpage()
  if open_tabs[tab] and #vim.api.nvim_list_tabpages() > 1 then
    -- codediff cleans up its session on TabClosed
    vim.cmd.tabclose()
    return
  end
  vim.cmd("CodeDiff " .. (args or ""))
end

return M
