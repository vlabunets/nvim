return {
  {
    "andythigpen/nvim-coverage",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = {
      "Coverage",
      "CoverageSummary",
      "CoverageLoad",
      "CoverageShow",
      "CoverageHide",
      "CoverageToggle",
      "CoverageClear",
    },
    config = function()
      require("coverage").setup()
    end,
  },

  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
    },
    config = function()
      -- Angular projects using @angular/build:unit-test must run specs through `ng test`
      -- (it compiles the app and sets up TestBed); bin/ng-vitest translates the adapter's vitest flags
      local ng_vitest = vim.fn.stdpath("config") .. "/bin/ng-vitest"
      local function uses_angular_unit_test(path)
        local root = vim.fs.root(path, "angular.json")
        if not root then
          return nil
        end
        local ok, lines = pcall(vim.fn.readfile, root .. "/angular.json")
        return ok and table.concat(lines, "\n"):find("@angular/build:unit-test", 1, true) and root or nil
      end

      require('neotest').setup {
        adapters = {
          require("neotest-vitest")({
            vitestCommand = function(path)
              if uses_angular_unit_test(path) then
                return ng_vitest
              end
              local root = vim.fs.root(path, "node_modules")
              return root and (root .. "/node_modules/.bin/vitest") or "vitest"
            end,
            cwd = function(path)
              return uses_angular_unit_test(path) or vim.fs.root(path, { "vitest.config.ts", "vitest.config.js", "package.json" })
            end,
          }),
        },
        -- Only parse spec files that are open; scanning a whole large project (hundreds of specs plus
        -- build/coverage dirs) at startup delays every run by minutes
        discovery = {
          enabled = false,
        },
        diagnostic = {
          enabled = false
        },
        floating = {
          border = EcoVim.ui.float.border or "rounded",
          max_height = 0.6,
          max_width = 0.6
        },
        highlights = {
          adapter_name = "NeotestAdapterName",
          border = "NeotestBorder",
          dir = "NeotestDir",
          expand_marker = "NeotestExpandMarker",
          failed = "NeotestFailed",
          file = "NeotestFile",
          focused = "NeotestFocused",
          indent = "NeotestIndent",
          namespace = "NeotestNamespace",
          passed = "NeotestPassed",
          running = "NeotestRunning",
          skipped = "NeotestSkipped",
          test = "NeotestTest"
        },
        icons = {
          child_indent = "│",
          child_prefix = "├",
          collapsed = "─",
          expanded = "╮",
          failed = "✖",
          final_child_indent = " ",
          final_child_prefix = "╰",
          non_collapsible = "─",
          passed = "✔",
          running = "",
          skipped = "ﰸ",
          unknown = "?"
        },
        output = {
          enabled = true,
          open_on_run = true,
        },
        run = {
          enabled = true
        },
        status = {
          enabled = true
        },
        strategies = {
          integrated = {
            height = 40,
            width = 120
          }
        },
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u"
          }
        }
      }
    end
  }
}
