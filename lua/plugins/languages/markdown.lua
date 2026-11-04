return {
  { "dhruvasagar/vim-table-mode", ft = { "markdown" } },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante", "copilot-chat", "codecompanion", "opencode_output" },
    opts = {
      render_modes = true,
      file_types = { "markdown", "Avante", "copilot-chat", "codecompanion", "opencode_output" },
      anti_conceal = { enabled = false },
      sign = {
        enabled = false,
      },
    },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    -- Needs yarn.lock: without it @chemzqm/neovim resolves to a version that drops msgpack-lite, which the app requires
    build = "cd app && yarn install --frozen-lockfile",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  }, }
