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

	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = false,
				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = true,
			},
			format = {
				indentSize = vim.o.shiftwidth,
				convertTabsToSpaces = vim.o.expandtab,
				tabSize = vim.o.tabstop,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = false,
				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = true,
			},
			format = {
				indentSize = vim.o.shiftwidth,
				convertTabsToSpaces = vim.o.expandtab,
				tabSize = vim.o.tabstop,
			},
		},
		completions = {
			completeFunctionCalls = true,
		},
	},
}
