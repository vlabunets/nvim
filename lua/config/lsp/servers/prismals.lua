-- Configure prismals with Neovim 0.11 API
vim.lsp.config("prismals", {
  settings = {
    prisma = {
      -- Format settings
      format = {
        enabled = true,
      },
      -- Trace settings (for debugging the language server)
      trace = {
        server = "off",
      },
    },
  },
  root_dir = function(bufnr, on_dir)
    -- The schema's project, else the nearest package.json
    local root = vim.fs.root(bufnr, { "schema.prisma", "prisma/schema.prisma" }) or vim.fs.root(bufnr, "package.json")
    if root then
      on_dir(root)
    end
  end,
  filetypes = { "prisma" },
})
