local parsers = {
  "tsx",
  "typescript",
  "javascript",
  "html",
  "angular",
  "css",
  "scss",
  "vue",
  "astro",
  "svelte",
  "gitcommit",
  "diff",
  "graphql",
  "json",
  "json5",
  "lua",
  "markdown",
  "markdown_inline",
  "prisma",
  "vim",
  "dockerfile",
  "terraform",
  "hcl",
  "yaml",
}

local function textobj(fn, query)
  return function()
    require("nvim-treesitter-textobjects.move")[fn](query, "textobjects")
  end
end

local function select(query)
  return function()
    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- `main` does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      -- `main` no longer enables features itself: start highlighting and indent per buffer.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(args)
          if not pcall(vim.treesitter.start, args.buf) then
            return
          end
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and vim.treesitter.query.get(lang, "indents") then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Neovim 0.12 built-in incremental selection (replaces nvim-treesitter-textsubjects).
      vim.keymap.set({ "x", "o" }, "<CR>", "an", { remap = true, desc = "Select parent node" })
      vim.keymap.set("x", "<BS>", "in", { remap = true, desc = "Select child node" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      -- Keep built-in ftplugin maps (e.g. python's ]] / ]m) from shadowing the moves below.
      vim.g.no_plugin_maps = true
    end,
    opts = {
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
      },
      move = {
        set_jumps = true, -- whether to set jumps in the jumplist
      },
    },
    keys = {
      { "]]", textobj("goto_next_start", "@jsx.element"), mode = { "n", "x", "o" }, desc = "Next JSX element" },
      { "]f", textobj("goto_next_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function start" },
      { "]m", textobj("goto_next_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Next class start" },
      { "]F", textobj("goto_next_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Next function end" },
      { "]M", textobj("goto_next_end", "@class.outer"), mode = { "n", "x", "o" }, desc = "Next class end" },
      { "[[", textobj("goto_previous_start", "@jsx.element"), mode = { "n", "x", "o" }, desc = "Prev JSX element" },
      { "[f", textobj("goto_previous_start", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function start" },
      { "[m", textobj("goto_previous_start", "@class.outer"), mode = { "n", "x", "o" }, desc = "Prev class start" },
      { "[F", textobj("goto_previous_end", "@function.outer"), mode = { "n", "x", "o" }, desc = "Prev function end" },
      { "[M", textobj("goto_previous_end", "@class.outer"), mode = { "n", "x", "o" }, desc = "Prev class end" },
      { "af", select("@function.outer"), mode = { "x", "o" }, desc = "Around function" },
      { "if", select("@function.inner"), mode = { "x", "o" }, desc = "Inside function" },
      { "ac", select("@class.outer"), mode = { "x", "o" }, desc = "Around class" },
      { "ic", select("@class.inner"), mode = { "x", "o" }, desc = "Inside class" },
      {
        "~",
        function()
          require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
        end,
        desc = "Swap with next parameter",
      },
    },
  },

  {
    "hiphish/rainbow-delimiters.nvim",
    event = "BufReadPre",
  },

  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPre",
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = false,          -- Auto close tags
          enable_rename = true,          -- Auto rename pairs of tags
          enable_close_on_slash = true   -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        --[[ per_filetype = {
            ["html"] = {
              enable_close = false
            }
          } ]]
      })
    end

  },

  {
    "wurli/contextindent.nvim",
    -- This is the only config option; you can use it to restrict the files
    -- which this plugin will affect (see :help autocommand-pattern).
    opts = { pattern = "*" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
