-- Main LSP configuration setup using the new vim.lsp.config API

-- Setup default configs for all LSP clients
vim.lsp.config('*', {
    capabilities = (function()
        local blink_ok, blink = pcall(require, 'blink.cmp')
        local capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

        -- Improved folding support
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }

        return capabilities
    end)(),
})

-- Inlay hints are enabled from LspAttach rather than a '*' on_attach: a server's own on_attach
-- (ours or nvim-lspconfig's) replaces the '*' one instead of running after it.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_inlay_hints", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if Nvim.lsp.inlay_hints and client and client:supports_method("textDocument/inlayHint", args.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})

-- Per-server capability tweaks, applied on attach. Kept here rather than in each server's on_attach,
-- because an on_attach replaces nvim-lspconfig's own (which some servers use for commands).
local capability_overrides = {
    -- Formatting is left to conform (prettier, stylua, ...)
    lua_ls = { documentFormattingProvider = false, documentRangeFormattingProvider = false },
    somesass_ls = { documentFormattingProvider = false, documentRangeFormattingProvider = false },
    vue_ls = { documentFormattingProvider = false },
    -- Servers used as the LSP formatting fallback
    bashls = { documentFormattingProvider = true },
    cssls = { documentFormattingProvider = true, documentRangeFormattingProvider = true },
    eslint = { documentFormattingProvider = true },
    graphql = { documentFormattingProvider = true },
    html = { documentFormattingProvider = true },
    jsonls = { documentFormattingProvider = true },
    prismals = { documentFormattingProvider = true },
    -- Inline color swatches
    tailwindcss = { colorProvider = true },
}

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_capabilities", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local overrides = client and capability_overrides[client.name]
        if overrides and client.server_capabilities then
            for capability, value in pairs(overrides) do
                client.server_capabilities[capability] = value
            end
        end
    end,
})

-- Load all the LSP server configurations from individual files
require("config.lsp.servers.lua_ls")
require("config.lsp.servers.jsonls")
require("config.lsp.servers.cssls")
require("config.lsp.servers.somesass_ls")
require("config.lsp.servers.eslint")
require("config.lsp.servers.tailwindcss")
require("config.lsp.servers.vue_ls")
require("config.lsp.servers.html")
require("config.lsp.servers.bashls")
require("config.lsp.servers.graphql")
require("config.lsp.servers.prismals")
require("config.lsp.servers.denols")
require("config.lsp.servers.yamlls")
require("config.lsp.servers.angularls")

-- Load TypeScript server config based on user preference
-- ts_ls is the default (stable); tsgo is the experimental, faster alternative
if Nvim.lsp.typescript_server == "ts_ls" then
    require("config.lsp.servers.ts_ls")
elseif Nvim.lsp.typescript_server == "tsgo" then
    require("config.lsp.servers.tsc")
end

-- Note: Server enabling is now handled by mason-lspconfig's automatic_enable feature
return {}
