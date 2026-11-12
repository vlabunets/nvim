return {
	{
		"razak17/tailwind-fold.nvim",
		opts = {
			min_chars = 50,
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
	},

	{
		"MaximilianLloyd/tw-values.nvim",
		keys = {
			{ "<Leader>cv", "<CMD>TWValues<CR>", desc = "Tailwind CSS values" },
		},
		opts = {
			border = Nvim.ui.float.border or "rounded", -- Valid window border style,
			show_unknown_classes = true, -- Shows the unknown classes popup
		},
	},
	{
		"axelvc/template-string.nvim",
		ft = {
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
		},
		config = true, -- run require("template-string").setup()
	},

	{
		"dmmulroy/tsc.nvim",
		cmd = { "TSC" },
		config = true,
	},

	{
		"dmmulroy/ts-error-translator.nvim",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		config = true,
	},

	{
		"monaqa/dial.nvim",
		keys = {
			{ "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, mode = "n" , desc = "Increment" },
			{ "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n" , desc = "Decrement" },
			{ "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n" , desc = "Increment (sequence)" },
			{ "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n" , desc = "Decrement (sequence)" },
			{ "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "x" , desc = "Increment" },
			{ "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "x" , desc = "Decrement" },
			{ "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "x" , desc = "Increment (sequence)" },
			{ "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "x" , desc = "Decrement (sequence)" },
			{ "<D-a>", function() require("dial.map").manipulate("increment", "normal") end, mode = "n" , desc = "Increment" },
			{ "<D-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n" , desc = "Decrement" },
			{ "g<D-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n" , desc = "Increment (sequence)" },
			{ "g<D-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n" , desc = "Decrement (sequence)" },
			{ "<D-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "x" , desc = "Increment" },
			{ "<D-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "x" , desc = "Decrement" },
			{ "g<D-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "x" , desc = "Increment (sequence)" },
			{ "g<D-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "x" , desc = "Decrement (sequence)" },
		},
		config = function()
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.hex,
					augend.date.alias["%Y/%m/%d"],
					augend.date.alias["%Y-%m-%d"],
					augend.date.alias["%m/%d"],
					augend.date.alias["%H:%M"],
					augend.constant.new({ elements = { "true", "false" } }),
					augend.constant.new({ elements = { "True", "False" } }),
					augend.constant.new({ elements = { "TRUE", "FALSE" } }),
					augend.constant.new({ elements = { "yes", "no" } }),
					augend.constant.new({ elements = { "Yes", "No" } }),
					augend.constant.new({ elements = { "on", "off" } }),
					augend.constant.new({ elements = { "On", "Off" } }),
					augend.constant.new({ elements = { "ON", "OFF" } }),
					augend.constant.new({ elements = { "enable", "disable" } }),
					augend.constant.new({ elements = { "enabled", "disabled" } }),
					augend.constant.new({ elements = { "&&", "||" }, word = false }),
				},
			})
			-- Adds the Tailwind augends to the group registered above
			require("lazy").load({ plugins = { "tailwindcss-dial.nvim" } })
		end,
	},

	{
		"ruicsh/tailwindcss-dial.nvim",
		lazy = true, -- loaded from dial.nvim's config, after dial registers its default group
		opts = {
			-- group = "default", -- optional, defaults to "default"
		},
	},
}
