local M = {}

--- Goto definition, skipping `.d.ts` results (e.g. React type declarations)
--- when there are real source locations to jump to.
M.goto_definition = function()
	-- In templates, a CSS class jumps to its stylesheet rule
	if vim.bo.filetype:match("html") and require("config.lsp.utils.css_class").goto_class() then
		return
	end

	vim.lsp.buf.definition({
		on_list = function(opts)
			local items = opts.items
			if #items > 1 then
				local filtered = vim.tbl_filter(function(item)
					return not item.filename:match("%.d%.ts$")
				end, items)
				if #filtered > 0 then
					items = filtered
				end
			end

			-- Overloads live in the same file: jump to the first one instead of opening quickfix
			local same_file = vim.iter(items):all(function(item)
				return item.filename == items[1].filename
			end)

			if #items == 1 or same_file then
				local item = items[1]
				vim.cmd("normal! m'")
				if vim.fn.bufnr(item.filename) ~= vim.api.nvim_get_current_buf() then
					vim.cmd.edit(vim.fn.fnameescape(item.filename))
				end
				vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
				vim.cmd("normal! zv")
				return
			end

			vim.fn.setqflist({}, " ", { title = opts.title, items = items })
			vim.cmd("botright copen")
		end,
	})
end

return M
