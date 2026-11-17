-- Alternative colorscheme. Select it in user.lua, e.g. Nvim.colorscheme = "onedark"
-- (variants: onedark, onedark_vivid, onedark_dark, onelight, vaporwave).
-- lazy.nvim loads it on demand when `:colorscheme onedark*` runs, so it costs nothing otherwise.
return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = true,
    priority = 1000,
    opts = {},
  },
}
