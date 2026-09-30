vim.lsp.config.tailwindcss = {
	on_attach = function(client, bufnr)
		-- Ensure colorProvider is supported for inline color swatches
		if client.server_capabilities then
			client.server_capabilities.colorProvider = true
		end
	end,

	filetypes = { "html", "mdx", "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" },

	settings = {
		tailwindCSS = {
			classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
			includeLanguages = {
				eelixir = "html-eex",
				eruby = "erb",
				typescript = "javascript",
				typescriptreact = "javascript",
			},
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidConfigPath = "error",
				invalidScreen = "error",
				invalidTailwindDirective = "error",
				invalidVariant = "error",
			},
			experimental = {
				classRegex = {
					"tw`([^`]*)",
					'tw="([^"]*)',
					'tw={"([^"}]*)',
					"tw\\.\\w+`([^`]*)",
					"tw\\(.*?\\)`([^`]*)",
					{ "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "classnames\\(([^)]*)\\)", "'([^']*)'" },
					{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
					{ "twMerge\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
					{ "twJoin\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
				},
			},
			validate = true,
		},
	},

	flags = {
		debounce_text_changes = 500,
		exit_timeout = 1000,
	},
}
