-- Commenting is Neovim's built-in gc / gcc. This plugin only supplies the right commentstring for
-- embedded languages (JSX, Vue, Svelte, ...), which the built-in asks for through get_option.
return {
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
    init = function()
      local get_option = vim.filetype.get_option
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.filetype.get_option = function(filetype, option)
        if option == "commentstring" then
          local ok, internal = pcall(require, "ts_context_commentstring.internal")
          local commentstring = ok and internal.calculate_commentstring()
          if commentstring then
            return commentstring
          end
        end
        return get_option(filetype, option)
      end
    end,
  },
}
