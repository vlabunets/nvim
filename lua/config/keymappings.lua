local keymap = vim.keymap.set
local silent = { silent = true }

table.unpack = table.unpack or unpack -- 5.1 compatibility

-- Fix moving forward in jumplist via <C-i> and <D-i>
keymap("n", "<C-I>", "<C-I>", { silent = true, desc = "Jump forward in jumplist" })
keymap("n", "<D-I>", "<C-I>", { silent = true, desc = "Jump forward in jumplist" })

-- Add down/up mapping for Cmd
keymap("n", "<D-d>", "<C-d>", { silent = true, desc = "Scroll half page down" })
keymap("n", "<D-u>", "<C-u>", { silent = true, desc = "Scroll half page up" })

-- H to move to the first non-blank character of the line
keymap("n", "H", "^", { silent = true, desc = "First non-blank character" })

-- Move selected line / block of text in visual mode
keymap("x", "K", ":move '<-2<CR>gv-gv", { silent = true, desc = "Move selection up" })
keymap("x", "J", ":move '>+1<CR>gv-gv", { silent = true, desc = "Move selection down" })

-- Keep visual mode indenting
keymap("v", "<", "<gv", { silent = true, desc = "Indent left (keep selection)" })
keymap("v", ">", ">gv", { silent = true, desc = "Indent right (keep selection)" })

-- Case change in visual mode
keymap("v", "`", "u", { silent = true, desc = "Lowercase selection" })
keymap("v", "<A-`>", "U", { silent = true, desc = "Uppercase selection" })

-- Jump to beginning with backspace
keymap("n", "<BS>", "^", { silent = true, desc = "First non-blank character" })

-- Format and save file by CTRL-S/CMD-S (plain :w still saves without formatting)
local function format_and_save()
	if vim.bo.modifiable and vim.bo.buftype == "" then
		pcall(require("config.lsp.functions").format)
	end
	vim.cmd.write()
end
keymap("n", "<C-s>", format_and_save, { silent = true, desc = "Format and save file" })
keymap("n", "<D-s>", format_and_save, { silent = true, desc = "Format and save file" })
-- Leave insert mode first so the formatter sees the final buffer state
keymap("i", "<C-s>", "<Esc><C-s>", { remap = true, silent = true, desc = "Format and save file" })
keymap("i", "<D-s>", "<Esc><D-s>", { remap = true, silent = true, desc = "Format and save file" })

-- Remove highlights
keymap("n", "<CR>", ":noh<CR><CR>", { silent = true, desc = "Clear search highlight" })
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Buffers
-- keymap("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
-- keymap("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })
keymap("n", "]]", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
keymap("n", "[[", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })
keymap("n", "<F19>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })
keymap("n", "gn", ":bn<CR>", { silent = true, desc = "Next buffer" })
keymap("n", "gm", ":bp<CR>", { silent = true, desc = "Previous buffer" })
keymap("n", "<S-q>", ":lua Snacks.bufdelete()<CR>", { silent = true, desc = "Close buffer" })
keymap("n", "<D-q>", ":lua Snacks.bufdelete()<CR>", { silent = true, desc = "Close buffer" })
keymap("n", "<D-w>", ":lua Snacks.bufdelete()<CR>", { silent = true, desc = "Close buffer" })

-- Don't yank on delete char
keymap("n", "x", '"_x', { silent = true, desc = "Delete char (no yank)" })
keymap("n", "X", '"_X', { silent = true, desc = "Delete char before (no yank)" })
keymap("v", "x", '"_x', { silent = true, desc = "Delete selection (no yank)" })
keymap("v", "X", '"_X', { silent = true, desc = "Delete lines (no yank)" })

-- Don't yank on visual paste
keymap("v", "p", '"_dP', { silent = true, desc = "Paste (keep register)" })

-- Avoid issues because of remapping <c-a> and <c-x> below
-- vim.cmd([[
--   nnoremap <Plug>SpeedDatingFallbackUp <c-a>
--   nnoremap <Plug>SpeedDatingFallbackDown <c-x>
-- ]])

-- Quickfix
keymap("n", "<Leader>,", ":cp<CR>", { silent = true, desc = "Quickfix previous" })
keymap("n", "<Leader>.", ":cn<CR>", { silent = true, desc = "Quickfix next" })

-- Toggle quicklist
keymap(
	"n",
	"<leader>q",
	"<cmd>lua require('utils').toggle_quicklist()<CR>",
	{ silent = true, desc = "Toggle quickfix list" }
)

-- Manually invoke speeddating in case switch.vim didn't work
-- keymap("n", "<C-a>", ":if !switch#Switch() <bar> call speeddating#increment(v:count1) <bar> endif<CR>", silent)
-- keymap("n", "<C-x>", ":if !switch#Switch({'reverse': 1}) <bar> call speeddating#increment(-v:count1) <bar> endif<CR>",
--   silent)

-- References for agent prompts: path relative to cwd, so the agent can open the exact spot
local function relative_path()
	local path = vim.fn.expand("%:.")
	if path == "" or vim.bo.buftype ~= "" then
		vim.notify("Buffer has no file", vim.log.levels.WARN)
		return nil
	end
	return path
end

keymap("n", "<leader>cy", function()
	local path = relative_path()
	if not path then
		return
	end
	local ref = path .. "#L" .. vim.fn.line(".")
	vim.fn.setreg("+", ref)
	vim.notify("Copied " .. ref)
end, { desc = "copy path#line" })

-- Fence languages that agents and Markdown renderers know by their short names
local fence_lang = {
	typescriptreact = "tsx",
	javascriptreact = "jsx",
	typescript = "ts",
	javascript = "js",
}

keymap("x", "<leader>cc", function()
	local path = relative_path()
	if not path then
		return
	end
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	if first > last then
		first, last = last, first
	end
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
	local lang = fence_lang[vim.bo.filetype] or vim.bo.filetype
	local block = string.format('```%s filename="%s" line=%d\n%s\n```\n', lang, path, first, table.concat(lines, "\n"))
	vim.fn.setreg("+", block)
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
	vim.notify(string.format("Copied %s#L%d-%d as code block", path, first, last))
end, { desc = "copy as code block" })

-- Adjust font size
keymap("n", "<M-=>", function()
	require("utils").adjust_font_size(1)
end, { silent = true, desc = "Increase font size" })
keymap("n", "<M-->", function()
	require("utils").adjust_font_size(-1)
end, { silent = true, desc = "Decrease font size" })
