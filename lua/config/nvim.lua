-- Default settings for the global `Nvim` table.
--
-- Personal settings don't go here: put them in lua/config/user.lua (gitignored; start from
-- lua/config/user.lua.example). This file loads first, then user.lua overrides its values.

local icons = require("utils.icons")

---@class NvimAI
---@field enabled boolean

---@class NvimPluginsAI
---@field avante NvimAI
---@field copilot NvimAI
---@field opencode NvimAI

---@class NvimPluginsCompletion
---@field ghost_text boolean Show inline completion preview (ghost text)

---@class NvimPluginsJumpBySubwords
---@field enabled boolean

---@class NvimPluginsGit
---@field blame_line boolean Show inline git blame on current line

---@class NvimPluginsRooter
---@field patterns string[] Root detection patterns for vim-rooter

---@class NvimPluginsProjects
---@field dev string[] Directories to scan for projects
---@field patterns string[] Patterns to detect project root directories

---@class NvimPlugins
---@field ai NvimPluginsAI AI plugin toggles
---@field completion NvimPluginsCompletion Completion settings
---@field jump_by_subwords NvimPluginsJumpBySubwords
---@field git NvimPluginsGit Git integration settings
---@field rooter NvimPluginsRooter Root detection settings
---@field projects NvimPluginsProjects Project management settings

---@class NvimUIFloat
---@field border "rounded"|"single"|"double"|"shadow"|"none" Floating window border style

---@class NvimUI
---@field float NvimUIFloat Floating window settings

---@class NvimLSPServerConfig
---@field cmd? string[] Command to start the server
---@field filetypes? string[] File types the server handles
---@field root_markers? string[] Root directory markers
---@field settings? table Server-specific settings

---@class NvimLSP
---@field typescript_server "tsgo"|"ts_ls" TypeScript server: "tsgo" (fast, native) or "ts_ls" (classic)
---@field ensure_installed string[] Additional LSP servers to install via Mason
---@field exclude string[] LSP servers to not auto-enable
---@field servers table<string, NvimLSPServerConfig> Custom LSP server configurations
---@field format_on_save boolean Auto-format on save (toggle at runtime with :LspToggleAutoFormat)
---@field inlay_hints boolean Show inlay hints from LSP servers

---@class NvimStatusline
---@field path_enabled boolean Show file path in statusline
---@field path "relative"|"absolute" Path display style

---@class NvimAutocmd
---@field event string|string[] Trigger event(s)
---@field pattern? string|string[] File pattern(s)
---@field command? string Vim command to run
---@field callback? function Lua callback to run

---@class NvimConfig
---@field colorscheme string Theme name (e.g. "tokyonight-night")
---@field ui NvimUI UI settings
---@field plugins NvimPlugins Plugin settings
---@field lsp NvimLSP LSP configuration
---@field formatters table<string, string[]> Override formatters per filetype
---@field linters table<string, string[]> Override linters per filetype
---@field autocmds table<string, NvimAutocmd> Custom autocommands
---@field plugin_overrides table<string, function|table> Override any plugin configuration
---@field statusline NvimStatusline Statusline configuration
---@field icons table<string, string> Icon definitions

---@type NvimConfig
Nvim = {
	-- Theme Configuration
	colorscheme = "tokyonight-night",

	-- UI Settings
	ui = {
		float = { border = "rounded" },
	},

	-- Plugin Settings
	plugins = {
		ai = {
			avante = { enabled = true },
			copilot = { enabled = true },
			opencode = { enabled = true },
		},
		completion = {
			ghost_text = true,
		},
		jump_by_subwords = {
			enabled = false,
		},
		git = {
			blame_line = true,
		},
		rooter = {
			-- Monorepo root markers (turbo, nx, pnpm, lerna, rush) are listed before .git
			-- so monorepo roots are preferred over plain git repos.
			-- Note: package.json is intentionally excluded to avoid sub-package detection in monorepos
			patterns = {
				"pnpm-workspace.yaml",
				"turbo.json",
				"nx.json",
				"lerna.json",
				"rush.json",
				".git",
				"_darcs",
				".bzr",
				".svn",
				"Makefile",
			},
		},
		projects = {
			-- Directories to scan for projects (sub-folders matching patterns)
			dev = { "~/Projects", "~/.config" },
			-- Patterns to detect project root directories
			patterns = { ".git" },
		},
	},

	-- LSP Configuration (add servers in user.lua)
	lsp = {
		-- TypeScript LSP server: "ts_ls" (stable, default) or "tsgo" (experimental, fast)
		typescript_server = "ts_ls",
		ensure_installed = {},
		exclude = { "copilot" },
		servers = {},
		format_on_save = false,
		inlay_hints = true,
	},

	-- Formatting Configuration (override in user.lua)
	formatters = {},

	-- Linting Configuration (override in user.lua)
	linters = {},

	-- Autocmd Configuration (add in user.lua)
	autocmds = {},

	-- Plugin Override Functions (define in user.lua)
	plugin_overrides = {},

	-- Statusline Configuration
	statusline = {
		path_enabled = false,
		path = "relative",
	},

	-- Icons (required)
	icons = icons,
}

-- Load the user configuration

local user_config = vim.fn.stdpath("config") .. "/lua/config/user.lua"
if vim.uv.fs_stat(user_config) then
	local ok, err = pcall(dofile, user_config)
	if not ok then
		vim.notify("Error loading user config: " .. err, vim.log.levels.ERROR, { title = "Nvim" })
	end
end
