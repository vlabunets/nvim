-- Dumps every global mapping with all plugins loaded to the file named by $OUT, as tab-separated
-- "mode lhs desc" lines. Read-only: it never syncs or updates plugins.
-- Run with: OUT=maps.tsv nvim --headless -c "luafile scripts/cheatsheet/dump-keymaps.lua"
local out_path = assert(vim.env.OUT, "set OUT to the output file")
local leader = vim.g.mapleader or "\\"

local function normalize(lhs)
  if lhs:sub(1, #leader) == leader then
    return "<leader>" .. lhs:sub(#leader + 1)
  end
  return lhs
end

vim.schedule(function()
  pcall(function()
    require("lazy").load({ plugins = vim.tbl_keys(require("lazy.core.config").plugins) })
  end)
  vim.schedule(function()
    local lines = {}
    for _, mode in ipairs({ "n", "x", "s", "o", "i", "t" }) do
      for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
        local lhs = normalize(map.lhs)
        if not lhs:match("^<Plug>") and not lhs:match("^<SNR>") then
          local desc = (map.desc or map.rhs or ""):gsub("[\r\n\t]", " ")
          lines[#lines + 1] = table.concat({ map.mode, lhs, desc }, "\t")
        end
      end
    end
    table.sort(lines)
    vim.fn.writefile(lines, out_path)
    vim.cmd("qa!")
  end)
end)
