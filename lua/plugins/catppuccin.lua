-- Alternative colorscheme. Select it in user.lua, e.g. EcoVim.colorscheme = "catppuccin-mocha"
-- (flavours: catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha).
-- lazy.nvim loads it on demand when `:colorscheme catppuccin*` runs, so it costs nothing otherwise.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },
}
