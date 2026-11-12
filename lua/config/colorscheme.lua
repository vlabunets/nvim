local present, tokyonight = pcall(require, "tokyonight")
if not present then
	return
end

local colors_ok, colors_mod = pcall(require, "tokyonight.colors")
if not colors_ok then
	return
end
local c = colors_mod.setup()

-- ╭──────────────────────────────────────────────────────────╮
-- │ Setup Colorscheme                                        │
-- ╰──────────────────────────────────────────────────────────╯
tokyonight.setup({
	style = "night",
	transparent = vim.g.neovide and true or false, -- Enable this to disable setting the background color
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	styles = {
		-- Style to be applied to different syntax groups
		-- Value is a table of highlight attributes (`:help nvim_set_hl`), e.g. { italic = true }.
		-- Strings like "italic" are not accepted and fail as soon as the theme isn't loaded from cache.
		comments = {},
		keywords = { italic = true },
		functions = {},
		variables = {},
		-- Background styles. Can be "dark", "transparent" or "normal"
		sidebars = vim.g.neovide and "dark" or "dark", -- style for sidebars, see below
		floats = vim.g.neovide and "dark" or "dark", -- style for floating windows
	},
	sidebars = { "qf", "help", "snacks_layout_box", "snacks_picker_list" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
	day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
	hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
	dim_inactive = false, -- dims inactive windows
	lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

	cache = true, -- When set to true, the theme will be cached for better performance
	---@type table<string, boolean|{enabled:boolean}>
	plugins = {
		-- enable all plugins when not using lazy.nvim
		-- set to false to manually enable/disable plugins
		all = package.loaded.lazy == nil,
		-- uses your plugin manager to automatically enable needed plugins
		-- currently only lazy.nvim is supported
		auto = true,
		-- add any plugins here that you want to enable
		-- for all possible plugins, see:
		--   * https://github.com/folke/tokyonight.nvim/tree/main/lua/tokyonight/groups
		-- telescope = true,
	},
	--- You can override specific color groups to use other groups or a hex color
	--- function will be called with a ColorScheme table
	on_colors = function(colors)
		colors.border = "#1A1B26"
	end,
	--- You can override specific highlights to use other groups or a hex color
	--- function will be called with a Highlights and ColorScheme table
	-- on_highlights = function(highlights, colors) end,
	on_highlights = function(hl, _color)
		local prompt = "#FFA630"
		local text = "#488dff"
		local none = "None"

		hl.TelescopeTitle = {
			fg = prompt,
			bg = none,
		}
		hl.TelescopeNormal = {
			bg = none,
			fg = none,
		}
		hl.TelescopeBorder = {
			bg = none,
			fg = none,
		}
		hl.TelescopeMatching = {
			fg = prompt,
			bg = none,
		}
		hl.MsgArea = {
			fg = c.fg_dark,
		}
	end,
})

-- Nvim accent groups and links: the dashboard, bufferline and winbar use these with every theme
local highlights = {
	-- Nvim Colors
	NvimPrimary = { fg = "#488dff" },
	NvimSecondary = { fg = "#FFA630" },
	NvimPrimaryBold = { bold = true, fg = "#488DFF" },
	NvimSecondaryBold = { bold = true, fg = "#FFA630" },
	NvimHeader = { bold = true, fg = "#488DFF" },
	NvimHeaderInfo = { bold = true, fg = "#FFA630" },
	NvimFooter = { bold = true, fg = "#FFA630" },
	NvimExplorerTitle = { bold = true, fg = "#FFA630" },
	-- Dashboard (snacks)
	SnacksDashboardHeader = { link = "NvimHeader" },
	SnacksDashboardKey = { link = "NvimPrimary" },
	SnacksDashboardFooter = { link = "NvimFooter" },
	-- Lines
	CursorLineNR = { link = "NvimSecondary" },
	LineNr = { link = "Comment" },
	-- Floats/Windows
	-- FloatBorder                   = { bg = "None", fg = "#488DFF" },
	-- Pmenu                         = { bg = "None", fg = "#488DFF" },
	-- WhichKeyFloat                 = { bg = "None", fg = "#488DFF" },
	-- BufferTabpageFill             = { fg = "None" },
	BqfPreviewBorder = { link = "FloatBorder" },
	LspInfoBorder = { link = "FloatBorder" },
	-- Misc
	GitSignsCurrentLineBlame = { link = "Comment" },
	-- Show changed lines in green, same as added ones
	GitSignsChange = { fg = "#9ece6a" },
	--GitSignsChange                = { link = "GitSignsAdd" },
	GitSignsChangeNr = { link = "GitSignsAddNr" },
	GitSignsChangeLn = { link = "GitSignsAddLn" },
	-- StatusLine                    = { bg = "None" },
	-- StatusLineNC                  = { bg = "None" },
	LspInlayHint = { link = "LspCodeLens" },
	SnacksPickerMatch = { link = "Boolean" },
}

-- Overrides tuned to tokyonight's palette: only applied while a tokyonight scheme is active,
-- otherwise they would paint tokyonight colors over another theme
local tokyonight_highlights = {
	NvimExplorerTitle = { bold = true, fg = "#FFA630", bg = "#16161e" },
	VertSplit = { bg = "NONE", fg = "#16161E" },
	WinSeparator = { bg = "NONE", fg = "#16161E" },
	RainbowDelimiterRed = { fg = c.blue, ctermfg = 9 },
	Boolean = { fg = "#F7768E" },
	-- Bufferline
	BufferLineFill = { bg = "#16161E", fg = "#565F89" },
	BufferLineTabSelected = { bg = "#16161E", fg = "#7AA2F7" },
	BufferLineBufferSelected = { bg = "#16161E", fg = "#C0CAF5", bold = true },
	-- BufferLineOffsetSeparator     = { bg = "#13141c", fg = "#13141c" },
	-- BufferLineSeparator           = { bg = "#13141c", fg = "#13141c" },
}

local function apply_highlights()
	local function set(groups)
		for group, hl in pairs(groups) do
			vim.api.nvim_set_hl(0, group, hl)
		end
	end
	set(highlights)
	if (vim.g.colors_name or ""):match("^tokyonight") then
		set(tokyonight_highlights)
	end
end

apply_highlights()
-- A :colorscheme switch clears custom highlights; re-apply the ones that fit the new theme
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("nvim_colorscheme_highlights", { clear = true }),
	callback = apply_highlights,
})
