return {
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      local default_linters = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        hcl = { "tflint" },
      }
      
      -- Merge with user custom linters
      lint.linters_by_ft = vim.tbl_deep_extend("force", default_linters, Nvim.linters or {})

      -- Linters that only make sense when the project configures them; otherwise they lint with their
      -- own defaults and contradict the project's eslint setup
      local required_config = {
        biomejs = { "biome.json", "biome.jsonc" },
        eslint_d = {
          "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs",
          "eslint.config.ts", "eslint.config.mts", "eslint.config.cts",
          ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json", ".eslintrc.yml", ".eslintrc.yaml",
        },
      }

      -- nvim-lint linter -> language server that reports the same diagnostics
      local lsp_equivalent = {
        eslint_d = "eslint",
        oxlint = "oxlint",
        biomejs = "biome",
      }

      local function linter_cmd(name)
        local linter = lint.linters[name]
        if type(linter) == "function" then
          linter = linter()
        end
        local cmd = type(linter) == "table" and linter.cmd or nil
        if type(cmd) == "function" then
          cmd = cmd()
        end
        return cmd
      end

      ---@param auto boolean true when triggered by an autocmd rather than <leader>l
      local function run(auto)
        local bufnr = vim.api.nvim_get_current_buf()
        local names = vim.tbl_filter(function(name)
          local markers = required_config[name]
          if markers and vim.fs.root(bufnr, markers) == nil then
            return false
          end
          if not auto then
            return true
          end
          -- Skip linters whose language server is attached: it reports the same diagnostics
          local server = lsp_equivalent[name]
          if server and #vim.lsp.get_clients({ bufnr = bufnr, name = server }) > 0 then
            vim.diagnostic.reset(lint.get_namespace(name), bufnr)
            return false
          end
          -- Stay quiet about linters that aren't installed; <leader>l still reports them
          local cmd = linter_cmd(name)
          return type(cmd) == "string" and vim.fn.executable(cmd) == 1
        end, lint.linters_by_ft[vim.bo[bufnr].filetype] or {})
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.keymap.set("n", "<leader>l", function()
        run(false)
      end, { desc = "lint file" })

      local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })

      -- The open-time lint runs before language servers attach; drop its results once the matching
      -- server takes over, so the same diagnostics don't show twice
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          for linter, server in pairs(lsp_equivalent) do
            if client and client.name == server then
              vim.diagnostic.reset(lint.get_namespace(linter), args.buf)
            end
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = group,
        callback = function(args)
          if vim.bo[args.buf].buftype == "" then
            run(true)
          end
        end,
      })
    end,
  },
}
