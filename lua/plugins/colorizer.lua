return {
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      -- Off: the built-in palette doesn't know project theme colors. Tailwind classes are still
      -- painted, from the tailwindcss server's colors (the plugin asks attached servers for them).
      -- Neovim's own LSP document colors are off in config/lsp/init.lua to avoid painting twice.
      enable_tailwind = false,
      enable_named_colors = true,
      enable_var_usage = true,
      enable_ansi = true,
    }
  },
}
