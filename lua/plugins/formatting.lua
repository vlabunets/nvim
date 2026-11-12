return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      local default_formatters = {
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        less = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        hcl = { "hclfmt" },
        javascript = { "biome", "prettierd", "prettier" },
        javascriptreact = { "biome", "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        lua = { "stylua" },
        markdown = { "prettierd", "prettier" },
        -- Both must run (sort imports, then format), so opt out of the global stop_after_first
        python = { "isort", "black", stop_after_first = false },
        sql = { "sql-formatter" },
        svelte = { "prettierd", "prettier" },
        typescript = { "biome", "prettierd", "prettier", "sql-formatter" },
        typescriptreact = { "biome", "prettierd", "prettier" },
        yaml = { "prettier" },
        xml = { "xmlformatter" }
      }
      
      -- Merge with user custom formatters
      local formatters_by_ft = vim.tbl_deep_extend("force", default_formatters, Nvim.formatters or {})

      conform.setup({
        default_format_opts = {
          lsp_format = "fallback",
          stop_after_first = true,
        },
        formatters_by_ft = formatters_by_ft,
        formatters = {
          -- Only use biome in projects that configure it (biome.json/.jsonc). Otherwise it would win
          -- over prettier (stop_after_first) and format with its own defaults, ignoring .prettierrc.
          biome = { require_cwd = true },
        },
      })

      -- Keymaps (<leader>cf, <C-s>) and format-on-save go through config.lsp.functions.format
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end

        conform.format({ async = true, range = range })
      end, { range = true })
    end,
  },
}
