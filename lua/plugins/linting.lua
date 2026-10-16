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
      lint.linters_by_ft = vim.tbl_deep_extend("force", default_linters, EcoVim.linters or {})

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

      vim.keymap.set("n", "<leader>l", function()
        local names = vim.tbl_filter(function(name)
          local markers = required_config[name]
          return not markers or vim.fs.root(0, markers) ~= nil
        end, lint._resolve_linter_by_ft(vim.bo.filetype))
        lint.try_lint(names)
      end, { desc = "lint file" })
    end,
  },
}
