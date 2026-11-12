-- Configure cssls with Neovim 0.11 API
vim.lsp.config("cssls", {
	settings = {
		css = {
			lint = {
				unknownAtRules = "ignore",
			},
		},
		scss = {
			lint = {
				unknownAtRules = "ignore",
			},
		},
	},
})
