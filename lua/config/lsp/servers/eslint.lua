-- Configure eslint with Neovim 0.11 API
-- Formatting capability is set in config/lsp/init.lua (capability_overrides)
vim.lsp.config("eslint", {
	settings = {
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		nodePath = "",
		onIgnoredFiles = "off",
		problems = {
			shortenToSingleLine = false,
		},
		quiet = false,
		rulesCustomizations = {},
		run = "onType",
		validate = "on",
		workingDirectory = {
			mode = "location",
		},
	},
	flags = {
		allow_incremental_sync = true,
		debounce_text_changes = 500,
	},
	exit_timeout = 2000,
})
