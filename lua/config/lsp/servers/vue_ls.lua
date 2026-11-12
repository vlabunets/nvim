-- Configure vue_ls (Vue Language Server) with Neovim 0.11 API
-- Note: mason-lspconfig v2.1.0 renamed "volar" to "vue_ls"
-- vue-language-server 3.x only works in hybrid mode: it handles template/CSS, and TypeScript in
-- .vue files comes from ts_ls through @vue/typescript-plugin (see servers/ts_ls.lua).
-- tsgo can't load that plugin, so Vue needs Nvim.lsp.typescript_server = "ts_ls".
vim.lsp.config("vue_ls", {
	filetypes = { "vue" },

	settings = {
		vue = {
			codeLens = {
				references = true,
				pugTools = false,
				scriptSetupTools = true,
			},
			completion = {
				autoImport = true,
				tagCasing = "kebab",
			},
		},
	},
})
