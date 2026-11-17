local M = {}

-- Buffers that are real files on disk (not pickers, terminals or scratch buffers)
local function is_file_buffer(bufnr)
	return vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= ""
end

--- Make a plugin's LSP rename hook save the files the language server edits.
--- snacks.rename and yazi.lsp.rename both expose `on_rename_file(from, to, rename?)`, which applies
--- the server's workspace/willRenameFiles edits (updated imports) but leaves them unsaved.
--- Only buffers the rename modified get written; buffers with unsaved work of yours stay as they are.
--- Written with noautocmd so format-on-save doesn't reformat files the rename only touched.
---@param mod table module with an on_rename_file function
function M.save_lsp_edits(mod)
	if type(mod) ~= "table" or type(mod.on_rename_file) ~= "function" or mod._saves_lsp_edits then
		return
	end
	local original = mod.on_rename_file
	mod.on_rename_file = function(...)
		local was_modified = {}
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			was_modified[bufnr] = vim.bo[bufnr].modified
		end

		local results = { original(...) }

		local saved = {}
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if is_file_buffer(bufnr) and vim.bo[bufnr].modified and not was_modified[bufnr] then
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd.update({ mods = { silent = true, noautocmd = true } })
				end)
				saved[#saved + 1] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
			end
		end
		if #saved > 0 then
			vim.notify("Updated imports in:\n" .. table.concat(saved, "\n"), vim.log.levels.INFO, { title = "Rename" })
		end

		return unpack(results)
	end
	mod._saves_lsp_edits = true
end

return M
