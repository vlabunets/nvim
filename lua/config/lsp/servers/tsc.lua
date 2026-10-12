-- Configure tsc: lspconfig's config for tsgo, the native TypeScript 7 server
-- Selected via EcoVim.lsp.typescript_server = "tsgo" (enabled in plugins/lsp.lua)
-- Inlay hints are shared with ts_ls: edit them in config/lsp/utils/typescript_preferences.lua
vim.lsp.config("tsc", {
	settings = require("config.lsp.utils.typescript_preferences").tsc_settings(),
})
