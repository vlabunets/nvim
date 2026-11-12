-- Configure ts_ls (TypeScript Language Server) with Neovim 0.11 API
-- This is the stable, traditional TypeScript server (typescript-language-server)
-- Selected via Nvim.lsp.typescript_server = "ts_ls" (the default)
-- Note: `gd` skips .d.ts results (see config/lsp/utils/definition.lua)
vim.lsp.config("ts_ls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
	},

	-- TypeScript support inside .vue files; vue_ls forwards its requests to this server
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
				languages = { "vue" },
			},
		},
	},

	-- No on_attach here: it would replace nvim-lspconfig's, which defines the :LspTypescript* commands.
	-- Inlay hints are enabled for every server in config/lsp/init.lua.

	-- Inlay hints and completion preferences are shared with tsgo: edit them in
	-- config/lsp/utils/typescript_preferences.lua
	settings = require("config.lsp.utils.typescript_preferences").ts_ls_settings(),
})
