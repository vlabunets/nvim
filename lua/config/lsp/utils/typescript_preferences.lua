-- Shared TypeScript/JavaScript preferences for both TypeScript servers.
-- Edit them here: ts_ls (typescript-language-server) and tsc (tsgo, see EcoVim.lsp.typescript_server)
-- each get them translated into the setting names they understand.
local M = {}

M.inlay_hints = {
  parameter_names = "all", -- "none" | "literals" | "all"
  parameter_names_when_argument_matches_name = true,
  function_parameter_types = true,
  variable_types = false,
  variable_types_when_type_matches_name = false,
  property_declaration_types = false,
  function_like_return_types = false,
  enum_member_values = true,
}

-- Insert parentheses and argument placeholders when completing a function (ts_ls only: tsgo has no such setting)
M.complete_function_calls = true

--- Settings for ts_ls: tsserver preference names (`includeInlay…`), one block per language.
function M.ts_ls_settings()
  local h = M.inlay_hints
  local language = {
    inlayHints = {
      includeInlayParameterNameHints = h.parameter_names,
      includeInlayParameterNameHintsWhenArgumentMatchesName = h.parameter_names_when_argument_matches_name,
      includeInlayFunctionParameterTypeHints = h.function_parameter_types,
      includeInlayVariableTypeHints = h.variable_types,
      includeInlayVariableTypeHintsWhenTypeMatchesName = h.variable_types_when_type_matches_name,
      includeInlayPropertyDeclarationTypeHints = h.property_declaration_types,
      includeInlayFunctionLikeReturnTypeHints = h.function_like_return_types,
      includeInlayEnumMemberValueHints = h.enum_member_values,
    },
    format = {
      indentSize = vim.o.shiftwidth,
      convertTabsToSpaces = vim.o.expandtab,
      tabSize = vim.o.tabstop,
    },
  }
  return {
    typescript = language,
    javascript = vim.deepcopy(language),
    completions = {
      completeFunctionCalls = M.complete_function_calls,
    },
  }
end

--- Settings for tsc (tsgo): VS Code-style names under the "js/ts" section that lspconfig's tsc
--- config uses, so these replace its defaults. tsgo ignores the ts_ls-style names above.
--- Indentation comes from each formatting request (the buffer's own options), so no format block.
function M.tsc_settings()
  local h = M.inlay_hints
  return {
    ["js/ts"] = {
      inlayHints = {
        parameterNames = {
          enabled = h.parameter_names,
          suppressWhenArgumentMatchesName = not h.parameter_names_when_argument_matches_name,
        },
        parameterTypes = { enabled = h.function_parameter_types },
        variableTypes = {
          enabled = h.variable_types,
          suppressWhenTypeMatchesName = not h.variable_types_when_type_matches_name,
        },
        propertyDeclarationTypes = { enabled = h.property_declaration_types },
        functionLikeReturnTypes = { enabled = h.function_like_return_types },
        enumMemberValues = { enabled = h.enum_member_values },
      },
    },
  }
end

return M
