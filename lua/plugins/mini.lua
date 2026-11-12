return {
  {
    "nvim-mini/mini.align",
    event = "VeryLazy",
    version = "*",
    opts = {}
  },
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    version = "*",
    config = function()
      require("mini.ai").setup()
    end,
  },
}
