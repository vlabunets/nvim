-- Lazygit in a snacks float, with `e` opening the file in the window lazygit was launched from.
--
-- lazygit's nvim-remote preset opens files with --remote-tab (a new tab). Instead, lazygit's edit
-- commands (set in plugins/snacks.lua) call M.edit() in this Neovim through $NVIM, which closes
-- lazygit, focuses the window it was launched from and opens the file there.
local M = {}

local origin_win ---@type integer?
local lazygit_win ---@type snacks.win?

--- Run a snacks lazygit function (Snacks.lazygit, .log, .log_file), remembering the current window.
---@param fn? fun(opts?: table): snacks.win
function M.open(fn)
	origin_win = vim.api.nvim_get_current_win()
	lazygit_win = (fn or Snacks.lazygit)()
end

local function target_window()
	if origin_win and vim.api.nvim_win_is_valid(origin_win) then
		return origin_win
	end
	-- Lazygit opened some other way: use the first regular (non-floating) window
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(win).relative == "" then
			return win
		end
	end
end

--- Called by lazygit's edit commands over RPC (see os.edit / os.editAtLine in plugins/snacks.lua).
--- Deferred, so the RPC call returns before lazygit (its caller) is closed.
---@param file string
---@param line? integer
function M.edit(file, line)
	vim.schedule(function()
		if lazygit_win and lazygit_win:valid() then
			lazygit_win:close()
		end
		lazygit_win = nil
		local win = target_window()
		if win then
			vim.api.nvim_set_current_win(win)
		end
		vim.cmd.edit(vim.fn.fnameescape(file))
		if line and line > 0 then
			pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
		end
	end)
	return ""
end

--- lazygit os.* settings (sh syntax). lazygit quotes {{filename}} only when needed, so the shell puts
--- the path in $f, doubles any single quotes and wraps it in '...' to make a Vimscript string.
---@param outside string command when not inside Neovim
---@param extra_args string extra M.edit arguments after the file, e.g. ", {{line}}"
local function remote_edit(outside, extra_args)
	return ([=[[ -z "$NVIM" ] && (%s) || (f=$(printf '%%s' {{filename}} | sed "s/'/''/g"); nvim --server "$NVIM" --remote-expr "v:lua.require'utils.lazygit'.edit('$f'%s)")]=]):format(
		outside,
		extra_args
	)
end

M.os_config = {
	editPreset = "nvim-remote", -- fills in the settings not set below
	edit = remote_edit("nvim -- {{filename}}", ""),
	editAtLine = remote_edit("nvim +{{line}} -- {{filename}}", ", {{line}}"),
	-- The command returns at once (Neovim opens the file), so lazygit mustn't wait for it like for a
	-- terminal editor. Overrides editInTerminal in ~/.config/lazygit/config.yml inside Neovim only.
	suspend = false,
}

return M
