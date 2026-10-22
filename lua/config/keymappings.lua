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

-- Open links under cursor in browser with gx
if vim.fn.has("macunix") == 1 then
	keymap(
		"n",
		"gx",
		"<cmd>silent execute '!open ' . shellescape('<cWORD>')<CR>",
		{ silent = true, desc = "Open link under cursor" }
	)
else
	keymap(
		"n",
		"gx",
		"<cmd>silent execute '!xdg-open ' . shellescape('<cWORD>')<CR>",
		{ silent = true, desc = "Open link under cursor" }
	)
end

-- Adjust font size
keymap("n", "<M-=>", function()
	require("utils").adjust_font_size(1)
end, { silent = true, desc = "Increase font size" })
keymap("n", "<M-->", function()
	require("utils").adjust_font_size(-1)
end, { silent = true, desc = "Decrease font size" })
