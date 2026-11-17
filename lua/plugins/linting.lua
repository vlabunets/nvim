return {
  {
    "mfussenegger/nvim-lint",
    -- Installs the standalone ESLint + eslint-plugin-sonarjs behind the `sonarjs` linter
    build = function()
      local dir = vim.fn.stdpath("config") .. "/linters/sonarjs"
      local result = vim.system({ "npm", "ci", "--no-audit", "--no-fund" }, { cwd = dir }):wait()
      if result.code ~= 0 then
        error("sonarjs: npm ci failed in " .. dir .. "\n" .. (result.stderr or ""))
      end
    end,
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      local default_linters = {
        javascript = { "eslint_d", "sonarjs" },
        typescript = { "eslint_d", "sonarjs" },
        javascriptreact = { "eslint_d", "sonarjs" },
        typescriptreact = { "eslint_d", "sonarjs" },
        svelte = { "eslint_d" },
        python = { "pylint" },
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        hcl = { "tflint" },
      }
      
      -- Sonar rules (eslint-plugin-sonarjs) on every JS/TS file, whatever the project's ESLint setup.
      -- Runs a private ESLint install with its own config (linters/sonarjs), so it needs nothing
      -- from the project. Reported as warnings, like SonarQube for IDE.
      local sonarjs_dir = vim.fn.stdpath("config") .. "/linters/sonarjs"
      lint.linters.sonarjs = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(bufnr)
        return {
          cmd = sonarjs_dir .. "/node_modules/.bin/eslint",
          args = {
            "--config", sonarjs_dir .. "/eslint.config.mjs",
            "--no-warn-ignored",
            "--format", "json",
            "--stdin",
            "--stdin-filename", filename,
          },
          -- ESLint ignores files outside its working directory when given --config
          cwd = vim.fs.root(bufnr, { ".git", "package.json" }) or vim.fs.dirname(filename),
          stdin = true,
          stream = "stdout",
          ignore_exitcode = true,
          parser = function(output, buf)
            local diagnostics = require("lint.linters.eslint").parser(output, buf)
            for _, d in ipairs(diagnostics) do
              d.source = "sonarjs"
              d.severity = vim.diagnostic.severity.WARN
            end
            return diagnostics
          end,
        }
      end

      -- True when a package.json above the buffer already pulls in eslint-plugin-sonarjs: the
      -- project's own eslint then reports these rules with the project's settings
      local function project_has_sonarjs(bufnr)
        local manifests = vim.fs.find("package.json", {
          upward = true,
          path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
          limit = math.huge,
        })
        for _, manifest in ipairs(manifests) do
          local ok, lines = pcall(vim.fn.readfile, manifest)
          if ok and table.concat(lines, "\n"):find('"eslint%-plugin%-sonarjs"') then
            return true
          end
        end
        return false
      end

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
          if name == "sonarjs" and project_has_sonarjs(bufnr) then
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
