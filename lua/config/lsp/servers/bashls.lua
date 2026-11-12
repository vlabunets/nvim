-- Configure bashls with Neovim 0.11 API
vim.lsp.config("bashls", {
	filetypes = { "sh", "bash", "zsh" },
	settings = {
		bashIde = {
			globPattern = "*@(.sh|.inc|.bash|.command)",
			shellcheckPath = "shellcheck",
			enableSourceErrorDiagnostics = true,
		},
	},
	root_dir = function(bufnr, on_dir)
		-- Typical bash project files, else the current directory
		on_dir(vim.fs.root(bufnr, { ".git", ".bashrc", "shell.nix" }) or vim.fn.getcwd())
	end,
})
