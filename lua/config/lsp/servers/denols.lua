-- Configure denols with Neovim 0.11 API
vim.lsp.config("denols", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"markdown",
	},
	-- Only attach inside a Deno project, to avoid conflicts with ts_ls and other JS/TS servers
	-- (a root_dir function, because nvim-lspconfig's own root_dir would win over root_markers)
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deps.ts", "import_map.json" })
		if root then
			on_dir(root)
		end
	end,
	init_options = {
		enable = true,
		lint = true,
		unstable = {},
	},
	settings = {
		deno = {
			enable = true,
			lint = true,
			suggest = {
				imports = {
					hosts = {
						["https://deno.land"] = true,
					},
				},
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
				parameterTypes = {
					enabled = true,
				},
				variableTypes = {
					enabled = true,
				},
				propertyDeclarationTypes = {
					enabled = true,
				},
				functionLikeReturnTypes = {
					enabled = true,
				},
				enumMemberValues = {
					enabled = true,
				},
			},
		},
	},
})
