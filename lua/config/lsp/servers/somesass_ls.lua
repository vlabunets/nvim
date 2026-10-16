-- Configure somesass_ls (Some Sass) with Neovim 0.11 API
-- Workspace-aware SCSS/Sass: follows @use/@forward/@import for variables, mixins and functions.
-- Runs alongside cssls; formatting stays with prettier via conform.
vim.lsp.config.somesass_ls = {
	filetypes = { "scss", "sass" },
	settings = {
		somesass = {
			workspace = {
				-- Relative to the workspace root; mirrors Angular's stylePreprocessorOptions.includePaths
				-- so imports like `@use "src/assets/styles/variables"` resolve.
				loadPaths = { ".", "src/assets/styles", "src/styles" },
			},
		},
	},
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
