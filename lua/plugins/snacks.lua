return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		config = function(_, opts)
			require("snacks").setup(opts)
			-- Explorer rename/move and Snacks.rename save the import updates the LSP makes
			require("utils.rename").save_lsp_edits(require("snacks.rename"))
		end,
		opts = {
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				width = 50,
				preset = {
					keys = {
						{ icon = vim.trim(Nvim.icons.fileNoBg) .. " ", key = "f", desc = "Find File", action = function() Snacks.picker.smart() end },
						{ icon = vim.trim(Nvim.icons.word) .. " ", key = "w", desc = "Find Word", action = function() Snacks.picker.grep() end },
						{ icon = vim.trim(Nvim.icons.fileRecent) .. " ", key = "h", desc = "Recents", action = function() Snacks.picker.recent() end },
						{ icon = vim.trim(Nvim.icons.timer) .. " ", key = "l", desc = "Load Last Session", action = ":SessionManager load_last_session" },
						{ icon = vim.trim(Nvim.icons.packageDown) .. " ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
						{ icon = vim.trim(Nvim.icons.package) .. " ", key = "m", desc = "Manage Plugins", action = ":Lazy" },
						{ icon = vim.trim(Nvim.icons.cog) .. " ", key = "s", desc = "Settings", action = ":e $MYVIMRC" },
						{ icon = vim.trim(Nvim.icons.exit) .. " ", key = "q", desc = "Exit", action = ":qa" },
					},
				},
				sections = {
					-- Neovim mark in ASCII, colored like the official logo (https://neovim.io): blue left bar,
					-- light-green diagonal (it also covers the top tip), green right bar, each shaded top to bottom
					function()
						local rows = {
							[[     .          .     ]],
							[[   ';;,.        ::'   ]],
							[[ ,:::;,,        :ccc, ]],
							[[,::c::,,,,.     :cccc,]],
							[[,cccc:;;;;;.    cllll,]],
							[[,cccc;.;;;;;,   cllll;]],
							[[:cccc; .;;;;;;. coooo;]],
							[[;llll;   ,:::::'loooo;]],
							[[;llll:    ':::::loooo:]],
							[[:oooo:     .::::llodd:]],
							[[.;ooo:       ;cclooo:.]],
							[[  .;oc        'coo;.  ]],
							[[    .'         .,.    ]],
						}
						local gradients = {
							left = { "#16B0ED", "#0F59B2" },
							diagonal = { "#88C649", "#439240" },
							right = { "#7DB643", "#367533" },
						}
						local function mix(from, to, t)
							local out = "#"
							for i = 2, 6, 2 do
								local x, y = tonumber(from:sub(i, i + 1), 16), tonumber(to:sub(i, i + 1), 16)
								out = out .. string.format("%02x", math.floor(x + (y - x) * t + 0.5))
							end
							return out
						end
						-- Column ranges of the bars in the art (1-based)
						local function part_of(r, c)
							if c >= 17 then
								return "right"
							elseif c <= 6 and r > 3 then
								return "left"
							end
							return "diagonal"
						end
						local items = {}
						for r, row in ipairs(rows) do
							local t = (r - 1) / (#rows - 1)
							local text = {}
							for c = 1, #row do
								local part = part_of(r, c)
								local g = gradients[part]
								local group = ("NvimLogo_%s_%d"):format(part, r)
								vim.api.nvim_set_hl(0, group, { fg = mix(g[1], g[2], t), bold = true })
								local last = text[#text]
								if last and last.hl == group then
									last[1] = last[1] .. row:sub(c, c)
								else
									text[#text + 1] = { row:sub(c, c), hl = group }
								end
							end
							items[#items + 1] = { text = text, align = "center" }
						end
						items[#items + 1] = { text = "", padding = 1 }
						return items
					end,
					function()
						local line = function(text)
							return { text = { { text, hl = "NvimHeaderInfo" } }, align = "center" }
						end
						return {
							line("┌────────────   Today is " .. os.date("%a %d %b") .. " ────────────┐"),
							line("│                                               │"),
							line("└───══───══───══───   " .. os.date("%H:%M") .. "  ───══───══───══────┘"),
							{ text = "", padding = 1 },
						}
					end,
					{ section = "keys", gap = 1, padding = 2 },
					function()
						local v = vim.version()
						local text = string.format(" v%d.%d.%d  󰂖 %d ", v.major, v.minor, v.patch, require("lazy").stats().count)
						return { text = { { text, hl = "NvimFooter" } }, align = "center" }
					end,
				},
			},
			gh = {},
			indent = {
				enabled = true,
				animate = {
					enabled = true,
					style = "out",
					easing = "linear",
					duration = {
						step = 15, -- ms per step
						total = 400, -- maximum duration
					},
				},
			},
			input = { enabled = true },
			notifier = { enabled = true },
			explorer = { enabled = true },
			picker = {
				enabled = true,
				-- Symbol pickers use the same kind icons as the completion menu (merged over snacks' own)
				icons = { kinds = require("utils.icons").kinds_padded() },
				explorer = {
					opts = {
						win = {
							list = {
								keys = {
									["<c-]>"] = "explorer_cd",
								},
							},
						},
					},
				},
				sources = {
					gh_issue = {},
					gh_pr = {},
					projects = {
						patterns = Nvim.plugins.projects.patterns,
						dev = Nvim.plugins.projects.dev,
					},
				},
				previewers = {
					git = {
						native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
					},
				},
				win = {
					-- input window
					input = {
						keys = {
							-- ["<Esc>"] = { "close", mode = { "n", "i" } },
							["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
							["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
							["<c-b>"] = { "list_scroll_up", mode = { "i", "n" } },
							["<c-f>"] = { "list_scroll_down", mode = { "i", "n" } },
						},
					},
				},
			},
			quickfile = { enabled = true },
			scroll = { enabled = false },
			statuscolumn = {
				enabled = true,
			},
			words = { enabled = false },
			zen = {
				on_open = function(win)
					Snacks.indent.disable(win)
					vim.wo.relativenumber = false
				end,
				on_close = function(win)
					Snacks.indent.enable(win)
					vim.wo.relativenumber = true
				end,
			},
		},
		keys = {
			-- ╭─────────────────────────────────────────────────────────╮
			-- │ Lazygit                                                 │
			-- ╰─────────────────────────────────────────────────────────╯
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>gla",
				function()
					Snacks.lazygit.log()
				end,
				desc = "Lazygit Log (cwd)",
			},
			{
				"<leader>glc",
				function()
					Snacks.lazygit.log_file()
				end,
				desc = "Lazygit Current File History",
			},
			-- ╭─────────────────────────────────────────────────────────╮
			-- │ Zen                                                     │
			-- ╰─────────────────────────────────────────────────────────╯
			{
				"<leader>z",
				function()
					Snacks.zen({ win = { width = 200 } })
				end,
				desc = "Zen Mode",
			},
			{
				"<leader>Z",
				function()
					Snacks.zen.zoom()
				end,
				desc = "Zoom Mode",
			},
			-- ╭─────────────────────────────────────────────────────────╮
			-- │ Picker                                                  │
			-- ╰─────────────────────────────────────────────────────────╯
			{
				"<C-e>",
				function()
					Snacks.picker.explorer()
				end,
				desc = "explorer",
			},
			{
				"<D-e>",
				function()
					Snacks.picker.explorer()
				end,
				desc = "explorer",
			},
			{
				"<C-p>",
				function()
					Snacks.picker.smart()
				end,
				desc = "smart files",
			},
			{
				"<D-p>",
				function()
					Snacks.picker.smart()
				end,
				desc = "smart files",
			},
			{
				"<S-p>",
				function()
					Snacks.picker.grep()
				end,
				desc = "grep",
			},
			{
				"<leader>pw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "grep word",
				mode = { "n", "v" },
			},

			{
				"<leader>pl",
				function()
					Snacks.picker.projects()
				end,
				desc = "projects list",
			},

			{
				"<leader>cd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "diagnostics",
			},

			{
				"<leader>sf",
				function()
					Snacks.picker.files()
				end,
				desc = "files",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "buffers",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.git_grep()
				end,
				desc = "git grep",
			},
			{
				"<leader>so",
				function()
					Snacks.picker.grep_buffers()
				end,
				desc = "grep open buffers",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.recent()
				end,
				desc = "recent files",
			},
			{
				"<leader>sH",
				function()
					Snacks.picker.command_history()
				end,
				desc = "command history",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "search history",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "quickfix list",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "color schemes",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "dotfiles",
			},

			{
				"<leader>gf",
				function()
					Snacks.picker.git_files()
				end,
				desc = "git files",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "git status",
			},
			{
				"<leader>glA",
				function()
					Snacks.picker.git_log()
				end,
				desc = "log",
			},
			{
				"<leader>glC",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "file commits",
			},
			-- ╭─────────────────────────────────────────────────────────╮
			-- │ Terminal                                                │
			-- ╰─────────────────────────────────────────────────────────╯
			{
				"<F12>",
				function()
					Snacks.terminal.toggle()
				end,
				desc = "terminal toggle",
				mode = { "n", "t" },
			},
		},
	},
}
