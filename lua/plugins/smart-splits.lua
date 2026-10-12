return {
	{
		"smart-splits-nvim/smart-splits.nvim",
		lazy = false, -- the tmux backend must load at startup so tmux knows the pane runs Neovim
		dependencies = {
			-- v3 moved multiplexer support into backend plugins; tmux side is vim-tmux-navigator
			{ "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
		},
		config = function()
			require("smart-splits").setup({
				mux = { backend = "smart-splits-backend-tmux" },
			})

			-- resizing splits
			-- these keymaps will also accept a range,
			-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
			vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left, { desc = "Resize split left" })
			vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down, { desc = "Resize split down" })
			vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up, { desc = "Resize split up" })
			vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right, { desc = "Resize split right" })
			-- moving between splits
			-- Note: <D-S-h/j/k/l> use Cmd+Shift because macOS blocks Cmd+h for "Hide"
			vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Go to left window" })
			vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Go to lower window" })
			vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Go to upper window" })
			vim.keymap.set("n", "<C-l>", function()
				if vim.bo.filetype == "snacks_picker_list" then
					vim.cmd("wincmd l")
				else
					require("smart-splits").move_cursor_right()
				end
			end, { desc = "Go to right window" })
			vim.keymap.set("n", "<D-S-h>", require("smart-splits").move_cursor_left, { desc = "Go to left window" })
			vim.keymap.set("n", "<D-S-j>", require("smart-splits").move_cursor_down, { desc = "Go to lower window" })
			vim.keymap.set("n", "<D-S-k>", require("smart-splits").move_cursor_up, { desc = "Go to upper window" })
			vim.keymap.set("n", "<D-S-l>", function()
				if vim.bo.filetype == "snacks_picker_list" then
					vim.cmd("wincmd l")
				else
					require("smart-splits").move_cursor_right()
				end
			end, { desc = "Go to right window" })

			-- smart-splits v3 removed move_cursor_previous; use the built-in previous-window jump
			vim.keymap.set("n", "<C-\\>", "<Cmd>wincmd p<CR>", { desc = "Go to previous window" })
			-- swapping buffers between windows
			vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
			vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
			vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
			vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
		end,
	},
}
