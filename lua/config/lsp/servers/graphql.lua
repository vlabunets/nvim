-- Configure graphql with Neovim 0.11 API
vim.lsp.config("graphql", {
  filetypes = { "graphql", "typescriptreact", "javascriptreact" },
  settings = {
    graphql = {
      validateSchemas = true,
      schema = {
        introspection = {
          enable = true,
        },
      },
      linting = {
        enable = true,
        rules = {
          deprecatedFields = "warn",
          noAnonymousOperations = "warn",
          noSchemaIntrospectionCustomRootNames = "warn",
          noDuplicateFields = "error",
          uniqueOperationNames = "error",
          uniqueFragmentNames = "error",
        },
      },
    },
  },
  -- Only attach in projects with a GraphQL config
  -- (a root_dir function, because nvim-lspconfig's own root_dir would win over root_markers)
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      '.graphqlrc',
      '.graphqlrc.json',
      '.graphqlrc.yaml',
      '.graphqlrc.yml',
      '.graphqlrc.js',
      '.graphqlrc.ts',
      '.graphqlrc.toml',
      'graphql.config.json',
      'graphql.config.js',
      'graphql.config.ts',
      'graphql.config.yaml',
      'graphql.config.yml',
      'graphql.config.toml',
    })
    if root then
      on_dir(root)
    end
  end,
})
