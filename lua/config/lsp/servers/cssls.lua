-- Configure cssls with Neovim 0.11 API
-- unknownAtRules: Tailwind's @apply/@tailwind etc. aren't errors
-- emptyRules: `.foo {}` placeholders while writing styles aren't warnings
local lint = {
	unknownAtRules = "ignore",
	emptyRules = "ignore",
}

vim.lsp.config("cssls", {
	settings = {
		css = { lint = lint },
		scss = { lint = vim.deepcopy(lint) },
		less = { lint = vim.deepcopy(lint) },
	},
})
