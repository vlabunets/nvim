-- Highlight on yank
local yank_group = vim.api.nvim_create_augroup("nvim_yank_highlight", {})
vim.api.nvim_create_autocmd("TextYankPost",
  { group = yank_group, callback = function() vim.hl.on_yank({ higroup = 'IncSearch', timeout = 100 }) end })
-- Disable diagnostics in node_modules (0 is current buffer only)
local buf_settings_group = vim.api.nvim_create_augroup("nvim_buf_settings", {})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { group = buf_settings_group, pattern = "*/node_modules/*", command = "lua vim.diagnostic.enable(false, { bufnr = 0 })" })
-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { group = buf_settings_group, pattern = { "*.txt", "*.md", "*.tex" },
  command = "setlocal spell" })
-- Show `` in specific files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { group = buf_settings_group, pattern = { "*.txt", "*.md", "*.json" },
  command = "setlocal conceallevel=0" })

-- Attach specific keybindings in which-key for specific filetypes.
-- which-key is required inside the callbacks, not here, so it still loads on VeryLazy.
local function which_key_setup()
  if not pcall(require, "which-key") then
    return nil
  end
  local ok, pwk = pcall(require, "plugins.which-key.setup")
  return ok and pwk or nil
end

local wk_group = vim.api.nvim_create_augroup("nvim_whichkey_ft", {})
vim.api.nvim_create_autocmd("BufEnter", { group = wk_group, pattern = { "package.json" },
  callback = function(args)
    local pwk = which_key_setup()
    if pwk then pwk.attach_npm(args.buf) end
  end })
vim.api.nvim_create_autocmd("BufEnter", { group = wk_group, pattern = { "*.test.js", "*.test.ts", "*.test.tsx", "*.spec.js", "*.spec.ts", "*.spec.tsx" },
  callback = function(args)
    local pwk = which_key_setup()
    if pwk then pwk.attach_tests(args.buf) end
  end })

-- Attach TypeScript keybindings when tsgo (lspconfig "tsc") or ts_ls connects
local ts_servers = { tsc = true, tsgo = true, ts_ls = true }
vim.api.nvim_create_autocmd("LspAttach", {
  group = wk_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and ts_servers[client.name] then
      local pwk = which_key_setup()
      if pwk then pwk.attach_typescript(args.buf) end
    end
  end,
})

-- User autocmds from Nvim.autocmds (set in lua/config/user.lua)
local user_group = vim.api.nvim_create_augroup("nvim_user_autocmds", { clear = true })
for name, spec in pairs(Nvim.autocmds or {}) do
  vim.api.nvim_create_autocmd(spec.event, {
    group = user_group,
    desc = name,
    pattern = spec.pattern,
    command = spec.command,
    callback = spec.callback,
  })
end
