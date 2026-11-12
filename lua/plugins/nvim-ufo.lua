-- ufo needs 'foldlevel' to stay at 99, so the built-in zm/zr (which just change 'foldlevel')
-- have no visible effect. Track the level per buffer and let ufo close folds instead.
local function fold_more()
  local level = vim.b.ufo_foldlevel
  if not level then
    level = 0
    for lnum = 1, vim.fn.line("$") do
      level = math.max(level, vim.fn.foldlevel(lnum))
    end
  end
  level = math.max(level - 1, 0)
  vim.b.ufo_foldlevel = level

  -- closeFoldsWith reopens every fold up to `level` (e.g. the collapsed imports), but zm should only
  -- ever close more. Remember the closed folds and close them again afterwards.
  local closed = {}
  local lnum, last = 1, vim.fn.line("$")
  while lnum <= last do
    local fold_end = vim.fn.foldclosedend(lnum)
    if fold_end ~= -1 then
      closed[#closed + 1] = { vim.fn.foldclosed(lnum), fold_end }
      lnum = fold_end
    end
    lnum = lnum + 1
  end

  require("ufo").closeFoldsWith(level)

  for _, range in ipairs(closed) do
    local start, fold_end = range[1], range[2]
    -- Each foldclose closes the next enclosing fold; stop once the original range is covered.
    for _ = 1, 20 do
      if vim.fn.foldclosed(start) ~= -1 and vim.fn.foldclosedend(start) >= fold_end then
        break
      end
      vim.cmd(start .. "foldclose")
    end
  end
end

-- lsp -> treesitter -> indent: servers without foldingRange (e.g. marksman) fall through to treesitter.
-- An empty result also falls through: ufo only asks the first capable client, which may answer
-- with zero ranges even when another attached server could fold the file.
-- nil means "not ready yet" (ufo retries later), so only fall through on an empty list.
local function nonempty(ranges)
  if ranges and #ranges == 0 then
    error("UfoFallbackException")
  end
  return ranges
end

local function fold_selector(bufnr)
  local ufo = require("ufo")
  local function fallback(err, provider)
    if type(err) == "string" and err:match("UfoFallbackException") then
      local ranges = ufo.getFolds(bufnr, provider)
      return provider == "indent" and ranges or nonempty(ranges)
    end
    return require("promise").reject(err)
  end
  return ufo.getFolds(bufnr, "lsp")
    :thenCall(nonempty)
    :catch(function(err)
      return fallback(err, "treesitter")
    end)
    :catch(function(err)
      return fallback(err, "indent")
    end)
end

return {
  {
    "kevinhwang91/nvim-ufo",
    -- Set up at startup: if setup runs during BufReadPre (e.g. from the LSP config), ufo attaches to
    -- the still-empty buffer and its line cache stays at 1 line, which breaks closeFoldsWith (zm).
    lazy = false,
    dependencies = "kevinhwang91/promise-async",
    config = function()
      -- ufo only asks the first client with foldingRange support. angularls answers .ts files with no
      -- ranges, and hangs while it loads the project, so let ts_ls (or treesitter) provide folds.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ufo_skip_angularls", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "angularls" then
            client.server_capabilities.foldingRangeProvider = nil
          end
        end,
      })

      local ufo = require("ufo")
      ufo.setup({
        fold_virt_text_handler = require("utils._ufo").handler,
        -- Collapse imports when a file opens. LSP providers label them "imports"; the treesitter
        -- fallback (used in Angular projects, see fold_selector) labels them by node type.
        close_fold_kinds_for_ft = { default = { "imports", "import_statement" } },
        provider_selector = function()
          return fold_selector
        end,
      })

      vim.keymap.set("n", "zR", function()
        vim.b.ufo_foldlevel = nil
        ufo.openAllFolds()
      end, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", function()
        vim.b.ufo_foldlevel = 0
        ufo.closeAllFolds()
      end, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", function()
        vim.b.ufo_foldlevel = nil
        ufo.openFoldsExceptKinds()
      end, { desc = "Open folds except imports" })
      vim.keymap.set("n", "zm", fold_more, { desc = "Fold one more level" })
    end,
  },
}
