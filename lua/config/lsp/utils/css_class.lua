-- Go to the CSS/SCSS rule of a class used in an HTML/Angular template (like WebStorm).
-- Resolves SCSS nesting, so `.card { &__title { &--active {} } }` matches `card__title--active`.
-- Looks in the component's own stylesheet first, then in all project stylesheets.

local M = {}

local style_exts = { "scss", "css", "sass", "less" }
local max_project_files = 1000

--- Class name under the cursor, if the cursor is in a class context:
--- class="...", [class.foo], [ngClass]="...", [class]="..."
---@return string?
local function class_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1

	-- Token of class-name characters around the cursor
	local s, e = col, col
	while s > 1 and line:sub(s - 1, s - 1):match("[%w_-]") do s = s - 1 end
	while e <= #line and line:sub(e, e):match("[%w_-]") do e = e + 1 end
	local token = line:sub(s, e - 1)
	if token == "" or not token:match("^[%a_-]") then return nil end

	-- Use treesitter so multi-line attributes work. htmlangular uses the `angular` parser;
	-- fall back to `html` if it is not installed
	local parser = vim.treesitter.get_parser(0, nil, { error = false })
		or vim.treesitter.get_parser(0, "html", { error = false })
	if not parser then return nil end
	parser:parse()
	local ok, node = pcall(vim.treesitter.get_node, { ignore_injections = false })
	local in_string = false
	while ok and node do
		if node:type() == "string" then in_string = true end
		if node:type() == "attribute" then
			-- Attribute name: `class`, `[class]`, `[ngClass]`, `ngClass` or `[class.foo]`
			local name = vim.treesitter.get_node_text(node, 0):match("^[^=%s]+") or ""
			if name == "class" or name == "ngClass" then
				return token
			end
			-- Bindings hold expressions: only string literals are class names
			if name == "[class]" or name == "[ngClass]" then
				return in_string and token or nil
			end
			return name:match("^%[class%.(.-)%]$") == token and token or nil
		end
		node = node:parent()
	end
	return nil
end

--- First word of a class ("card" for "card-list__title--active"); nested SCSS only
--- guarantees this part appears literally in the stylesheet
local function root_word(class_name)
	return class_name:match("^[%w]+") or class_name
end

local function read_lines(path)
	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
		return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	end
	local f = io.open(path, "r")
	if not f then return nil end
	local content = f:read("*a")
	f:close()
	return content
end

--- Combine a nested selector with its parent selectors (SCSS `&` semantics)
local function resolve_selector(parents, sel)
	if #parents == 0 then return { sel } end
	local out = {}
	for _, parent in ipairs(parents) do
		if sel:find("&", 1, true) then
			table.insert(out, (sel:gsub("&", function() return parent end)))
		else
			table.insert(out, parent .. " " .. sel)
		end
	end
	return out
end

--- Find rules in a stylesheet whose resolved selector contains `.class_name`
---@return {filename: string, lnum: integer, col: integer, text: string}[]
local function find_in_file(path, class_name)
	local content = read_lines(path)
	if not content or not content:find(root_word(class_name), 1, true) then
		return {}
	end

	local lang = path:match("%.css$") and "css" or "scss"
	local ok, parser = pcall(vim.treesitter.get_string_parser, content, lang)
	if not ok or not parser then return {} end
	local root = parser:parse()[1]:root()

	local results = {}
	local pattern = "%." .. vim.pesc(class_name) .. "[^%w_-]"

	--- The class must be in the selector's target (last compound), so `.row .author` is not a match for `row`
	local function targets_class(full)
		local last = full:gsub("%b()", ""):match("([^%s>+~]+)%s*$") or ""
		return (last .. " "):find(pattern) ~= nil
	end

	local function walk(node, parents, parent_matched)
		for child in node:iter_children() do
			local next_parents, matched = parents, parent_matched
			if child:type() == "rule_set" then
				local selectors = child:child(0)
				if selectors and selectors:type() == "selectors" then
					next_parents = {}
					local nodes = {} -- resolved selector -> its selector node, to jump to the exact line
					for sel_node in selectors:iter_children() do
						if sel_node:named() then
							local sel = vim.treesitter.get_node_text(sel_node, content):gsub("%s+", " ")
							for _, full in ipairs(resolve_selector(parents, sel)) do
								table.insert(next_parents, full)
								nodes[full] = sel_node
							end
						end
					end
					-- Skip nested rules (`&:hover`, `.icon`) of a rule that already matched
					matched = false
					for _, full in ipairs(next_parents) do
						if targets_class(full) then
							matched = true
							if parent_matched then break end
							local row, col = nodes[full]:start()
							table.insert(results, {
								filename = path,
								lnum = row + 1,
								col = col + 1,
								text = full,
							})
							break
						end
					end
				end
			end
			walk(child, next_parents, matched)
		end
	end
	walk(root, {}, false)
	return results
end

--- Stylesheets next to the template: foo.component.html -> foo.component.{scss,css,...}
local function sibling_stylesheets()
	local base = vim.fn.expand("%:p:r")
	local files = {}
	for _, ext in ipairs(style_exts) do
		local path = base .. "." .. ext
		if vim.uv.fs_stat(path) then table.insert(files, path) end
	end
	return files
end

--- Project stylesheets containing `needle` (ripgrep, fixed string)
local function project_stylesheets(needle, skip)
	if vim.fn.executable("rg") == 0 then return {} end
	local root_dir = vim.fs.root(0, { ".git", "package.json" }) or vim.fn.getcwd()
	local cmd = { "rg", "--files-with-matches", "--fixed-strings", "--", needle, root_dir,
		"--glob", "!node_modules", "--glob", "!dist", "--glob", "!documentation", "--glob", "!.angular" }
	for _, ext in ipairs(style_exts) do vim.list_extend(cmd, { "--glob", "*." .. ext }) end

	local out = vim.system(cmd, { text = true }):wait()
	local files = {}
	for path in (out.stdout or ""):gmatch("[^\n]+") do
		if not skip[path] then table.insert(files, path) end
		if #files >= max_project_files then break end
	end
	return files
end

local function jump(item)
	vim.cmd("normal! m'")
	if vim.fn.bufnr(item.filename) ~= vim.api.nvim_get_current_buf() then
		vim.cmd.edit(vim.fn.fnameescape(item.filename))
	end
	vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
	vim.cmd("normal! zv")
end

--- Try to jump to the CSS rule of the class under the cursor.
---@return boolean handled false if the cursor is not on a CSS class
function M.goto_class()
	local class_name = class_under_cursor()
	if not class_name then return false end

	-- 1. The component's own stylesheet
	local results, seen = {}, {}
	for _, path in ipairs(sibling_stylesheets()) do
		seen[path] = true
		vim.list_extend(results, find_in_file(path, class_name))
	end

	-- 2. Anywhere in the project (global styles, shared partials, other components):
	--    files with the literal `.class` first, then files with its first word (SCSS nesting)
	for _, needle in ipairs({ "." .. class_name, root_word(class_name) }) do
		if #results > 0 then break end
		for _, path in ipairs(project_stylesheets(needle, seen)) do
			seen[path] = true
			vim.list_extend(results, find_in_file(path, class_name))
		end
	end

	if #results == 0 then
		vim.notify("No CSS rule found for ." .. class_name, vim.log.levels.WARN)
	elseif #results == 1 then
		jump(results[1])
	else
		vim.fn.setqflist({}, " ", { title = "CSS: ." .. class_name, items = results })
		vim.cmd("botright copen")
	end
	return true
end

return M
