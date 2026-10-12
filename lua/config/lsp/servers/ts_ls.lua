-- Configure ts_ls (TypeScript Language Server) with Neovim 0.11 API
-- This is the stable, traditional TypeScript server (typescript-language-server)
-- Selected via EcoVim.lsp.typescript_server = "ts_ls" (the default)
-- Note: `gd` skips .d.ts results (see config/lsp/utils/definition.lua)
vim.lsp.config.ts_ls = {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},

	on_attach = function(client, bufnr)
		if EcoVim.lsp.inlay_hints then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,

	-- Inlay hints and completion preferences are shared with tsgo: edit them in
	-- config/lsp/utils/typescript_preferences.lua
	settings = require("config.lsp.utils.typescript_preferences").ts_ls_settings(),
}
