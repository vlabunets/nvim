-- Show the diagnostic under the cursor after ]g / [g (replaces the deprecated `float` jump option)
local function open_diagnostic_float(_, bufnr)
	vim.diagnostic.open_float({
		bufnr = bufnr,
		scope = "cursor",
		focus = false,
		border = EcoVim.ui.float.border,
		max_width = 100,
	})
end

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"mason-org/mason.nvim",
				"mason-org/mason-lspconfig.nvim",
			},
			{ "b0o/schemastore.nvim", lazy = true },
		},
		config = function()
			-- Load diagnostic configuration
			require("config.lsp.config")
			-- Load LSP functions
			require("config.lsp.functions")

			-- Set up Mason
			require("mason").setup({
				ui = {
					border = EcoVim.ui.float.border or "rounded",
				},
			})

			-- Determine TypeScript server based on user preference
			-- ts_server is the Mason package name; ts_config is the lspconfig config to enable.
			-- lspconfig renamed "tsgo" to "tsc" (the old name is a deprecated alias that warns on
			-- every start), so tsgo is enabled through "tsc", which finds Mason's tsgo binary on PATH.
			local ts_server = EcoVim.lsp.typescript_server or "ts_ls"
			local ts_config = ts_server == "tsgo" and "tsc" or "ts_ls"

			-- Set up Mason-lspconfig
			local default_servers = {
				"bashls",
				"biome",
				"clangd",
				"copilot", -- copilot-language-server, required by copilot-lsp (enabled in plugins/ai/copilot.lua)
				"cssls",
				"denols",
				"dockerls",
				"eslint",
				"graphql",
				"html",
				"jsonls",
				"lua_ls",
				"marksman",
				"oxlint",
				"prismals",
				"pyright",
				"somesass_ls",
				"sqlls",
				"tailwindcss",
				"terraformls",
				"tflint",
				ts_server,
				"vue_ls",
				"yamlls",
			}

			-- Merge default servers with user custom servers
			local ensure_installed = vim.list_extend(default_servers, EcoVim.lsp.ensure_installed or {})

			-- Build exclude list: always exclude copilot + both TypeScript servers (enabled explicitly below)
			local exclude = vim.list_extend({ "ts_ls", "tsgo", "copilot" }, EcoVim.lsp.exclude or {})

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				-- Automatically enable installed servers via vim.lsp.enable
				automatic_enable = {
					exclude = exclude,
				},
			})

			-- Enable only the selected TypeScript server, unless the user excluded it
			if not vim.tbl_contains(EcoVim.lsp.exclude or {}, ts_server) then
				vim.lsp.enable(ts_config)
			end

			-- Load LSP configurations using vim.lsp.config API
			require("config.lsp")

			-- Load user custom LSP server configs
			for name, config in pairs(EcoVim.lsp.servers or {}) do
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end
		end,
		keys = {
			-- Mason
			{ "<leader>cm", "<cmd>Mason<CR>", desc = "Mason LSP manager" },
			-- Nvim 0.12 built-in :lsp command; lspconfig no longer defines :Lsp* when it exists
			{ "<leader>cli", "<cmd>checkhealth vim.lsp<CR>", desc = "LSP Info" },
			{ "<leader>clr", "<cmd>lsp restart<CR>", desc = "LSP Restart" },
			{ "<leader>cls", "<cmd>lsp stop<CR>", desc = "LSP Stop" },
			{ "<leader>clS", "<cmd>lsp enable<CR>", desc = "LSP Start" },

			-- Navigation
			{ "gd", function() require("config.lsp.utils.definition").goto_definition() end, desc = "Goto Definition" },
			{ "gr", function() vim.lsp.buf.references({ includeDeclaration = false }) end, desc = "Goto References" },
			{ "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
			{ "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },

			-- Info
			{ "K", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end, desc = "Hover / Peek Fold" },
			{ "L", vim.lsp.buf.signature_help, desc = "Signature Help", mode = { "n" } },

			-- Diagnostics
			{ "gl", function() vim.diagnostic.open_float({ border = EcoVim.ui.float.border, max_width = 100 }) end, desc = "Line Diagnostics" },
			{ "]g", function() vim.diagnostic.jump({ count = 1, on_jump = open_diagnostic_float }) end, desc = "Next Diagnostic" },
			{ "[g", function() vim.diagnostic.jump({ count = -1, on_jump = open_diagnostic_float }) end, desc = "Prev Diagnostic" },

			-- Code actions
			{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
			{ "<C-Space>", vim.lsp.buf.code_action, desc = "Code Action" },

			-- Refactoring
			-- <leader>cr (Rename Symbol) is handled by inc-rename.nvim
			{ "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },

			-- Formatting
			-- Through conform (LSP as fallback) so filetypes without an LSP formatter, like htmlangular, still format
			{ "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "Format Document" },
			{ "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "Format Range", mode = "v" },

			-- Symbols
			{ "<leader>ss", vim.lsp.buf.document_symbol, desc = "Document Symbols" },
			{ "<leader>sS", vim.lsp.buf.workspace_symbol, desc = "Workspace Symbols" },
		},
	},
}
