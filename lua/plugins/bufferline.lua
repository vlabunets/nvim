return {
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local bufferline = require("bufferline")
			bufferline.setup({
				options = {
					close_command = function(n)
						Snacks.bufdelete(n)
					end,
					right_mouse_command = function(n)
						Snacks.bufdelete(n)
					end,
					show_buffer_close_icons = false,
					show_duplicate_prefix = true,
					separator_style = { "", "" },
					always_show_bufferline = true,
					style_preset = bufferline.style_preset.no_italic,
					numbers = function(opts)
						return string.format("%s", opts.ordinal)
					end,
					custom_filter = function(buf_number)
						-- filter out filetypes you don't want to see
						if vim.bo[buf_number].filetype ~= "qf" then
							return true
						end
					end,
					offsets = {
						{
							filetype = "snacks_layout_box",
							text = "",
							highlight = "EcovimExplorerTitle",
							text_align = "center",
							separator = false,
						},
					},
				},
			})
		end,
		keys = {
			{ "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "Go to buffer 1" },
			{ "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "Go to buffer 2" },
			{ "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "Go to buffer 3" },
			{ "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "Go to buffer 4" },
			{ "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "Go to buffer 5" },
			{ "<A-6>", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "Go to buffer 6" },
			{ "<A-7>", "<cmd>BufferLineGoToBuffer 7<CR>", desc = "Go to buffer 7" },
			{ "<A-8>", "<cmd>BufferLineGoToBuffer 8<CR>", desc = "Go to buffer 8" },
			{ "<A-9>", "<cmd>BufferLineGoToBuffer 9<CR>", desc = "Go to buffer 9" },
			{ "<Leader>bb", "<cmd>BufferLineMovePrev<CR>", desc = "Move back" },
			{ "<Leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Close Left" },
			{ "<Leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Close Right" },
			{ "<Leader>bn", "<cmd>BufferLineMoveNext<CR>", desc = "Move next" },
			{ "<Leader>bp", "<cmd>BufferLinePick<CR>", desc = "Pick Buffer" },
			{ "<Leader>bP", "<cmd>BufferLineTogglePin<CR>", desc = "Pin/Unpin Buffer" },
			{ "<Leader>bsd", "<cmd>BufferLineSortByDirectory<CR>", desc = "Sort by directory" },
			{ "<Leader>bse", "<cmd>BufferLineSortByExtension<CR>", desc = "Sort by extension" },
			{ "<Leader>bsr", "<cmd>BufferLineSortByRelativeDirectory<CR>", desc = "Sort by relative dir" },
		},
	},
}
