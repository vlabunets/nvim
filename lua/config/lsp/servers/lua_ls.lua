-- Configure lua_ls with Neovim 0.11 API
-- Note: lazydev.nvim manages workspace.library and Neovim API types automatically
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim', 'Nvim' },
			},
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
			format = {
				enable = false, -- Let other formatters handle this
			},
			completion = {
				callSnippet = "Replace",
			},
			hint = { enable = true },
		},
	},
})
