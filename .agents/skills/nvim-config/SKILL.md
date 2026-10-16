---
name: nvim-config
description: Work on this EcoVim-based Neovim config (Lua + lazy.nvim) at ~/.config/nvim. Use whenever the task touches the Neovim setup — adding, removing or configuring plugins, overriding plugin options, keymaps, which-key groups, options, autocommands, LSP servers, formatters/linters, AI plugins (avante, copilot, opencode, mcphub), or fixing startup errors and lazy.nvim tracebacks ("Failed to source", "module not found", deprecation warnings) — even if the user doesn't say "nvim config" explicitly.
---

# Neovim config (EcoVim)

This config is a fork of **EcoVim**, run on macOS (Apple Silicon, Homebrew at `/opt/homebrew`) with **lazy.nvim**. Neovim runs on **LuaJIT, so Lua 5.1 semantics apply**: no `//`, no native bitwise operators (use `bit`), and `table.unpack` is shimmed to `unpack`. If `AGENTS.md` exists at the root, read it too. It is gitignored and local-only, and it wins over this skill on conflicts.

## How the config is wired

```
init.lua                    loads, in order: config.EcoVim → utils.globals/functions →
                            config.options → config.filetypes → config.lazy →
                            config.keymappings → config.autocmds → internal.*
lua/config/EcoVim.lua       upstream DEFAULTS for the global `EcoVim` table. Do not edit.
lua/config/user.lua         the user's overrides of `EcoVim.*` (gitignored, loaded after defaults)
lua/config/user.lua.example upstream template for user.lua
lua/config/lazy.lua         bootstrap + lazy.setup({ spec = { import = "plugins" }, ... })
                            also turns EcoVim.plugin_overrides into extra specs
lua/config/keymappings.lua  global keymaps
lua/config/lsp/             vim.lsp.config('*', …) + one file per server in servers/
                            (servers enabled by mason-lspconfig automatic_enable)
lua/plugins/*.lua           one spec file per plugin or feature
lua/plugins/{ai,languages,git}/  imported via plugins/init.lua
lua/plugins/which-key/setup.lua  which-key setup and leader group/mapping registrations
lua/internal/               hand-written statusline, winbar, cursorword (not plugins)
lua/utils/                  shared helpers and icons
```

Key facts that change how you edit:
- **`defaults = { lazy = false }`**: plugins load eagerly unless a spec sets `event`/`cmd`/`ft`/`keys` or `lazy = true`. New specs should still lazy-load where they can.
- **`rocks = { enabled = false }`**: LuaRocks is off. Any Lua library a plugin `require`s must be listed as a plain plugin in `dependencies`. avante already does this with `mega.cmdparse` + `mega.logging`.
- **`checker = { enabled = true }`**: lazy checks for updates in the background. `lazy-lock.json` holds the pinned commits.
- Feature toggles live on the `EcoVim` global, for example `enabled = EcoVim.plugins.ai.avante.enabled`. Respect them and don't hardcode `enabled = true`.

## Where a change belongs (decide this first)

The repo tracks upstream EcoVim, so every edit to a tracked upstream file can conflict on the next `git pull`. Prefer the least-invasive place:

1. **Personal preference or toggle** (colorscheme, enabling an AI plugin, extra Mason servers, formatter per filetype): edit `lua/config/user.lua` by setting `EcoVim.*` fields. Check `EcoVim.lua` / `user.lua.example` for the field name and its `---@class` type.
2. **Tweaking an existing plugin's options**: add to `EcoVim.plugin_overrides` in `user.lua`:
   ```lua
   EcoVim.plugin_overrides["snacks.nvim"] = { picker = { layout = "vertical" } }        -- table: deep-merged
   EcoVim.plugin_overrides["blink.cmp"] = function(_, opts) opts.completion.menu.auto_show = false end
   ```
   The key is the plugin's short name (repo name). This only works for plugins configured via `opts`. If the spec uses `config = function() … end` without `opts` (for example, `formatting.lua`), use the `EcoVim.*` hook the spec reads (`EcoVim.formatters`), or edit the spec.
3. **A new plugin**: create a new file in `lua/plugins/` (or the matching subfolder: `ai/`, `languages/`, `git/`). New files rarely conflict upstream.
4. **Editing an upstream spec or core file**: only when 1–3 can't do it. Keep the diff small and say in your reply that the file is upstream-tracked.

Never edit `lua/config/EcoVim.lua` for personal settings. Never edit anything under `~/.local/share/nvim/` (lazy overwrites it).

## Writing a new plugin spec

```lua
return {
  {
    "author/plugin.nvim",
    event = "VeryLazy",                 -- or cmd / ft / keys
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>xx", "<cmd>PluginCmd<cr>", desc = "Plugin: do thing" },
    },
    opts = {},                          -- lets plugin_overrides work on it later
  },
}
```

- Prefer `opts`. Use `config = function(_, opts) require("x").setup(opts) … end` only when extra logic is needed.
- Match the indentation of the file you're in. The repo mixes 2-space and tab files (for example, `ai/avante.lua` uses tabs). `stylua` is the Lua formatter (`<leader>f` via conform).
- Secrets (API keys) come from `os.getenv(...)`. Never write them as literals, not even in the gitignored `user.lua`.

## Keymaps

- Plugin-specific keymaps go in the spec's `keys`. Global keymaps go in `lua/config/keymappings.lua` (uses `local keymap = vim.keymap.set`).
- Leader groups and many leader mappings are registered in `lua/plugins/which-key/setup.lua`. Check there before choosing a `<leader>` key, and add new groups there.
- Check for collisions before adding: `grep -rn '"<leader>xx"' lua/` and in Neovim `:verbose nmap <leader>xx`.
- Always set `desc`. Don't change the leader key or existing core mappings unless asked.

## LSP, formatting, linting

- **New language server**: add `lua/config/lsp/servers/<name>.lua` using `vim.lsp.config("<name>", { … })` (copy the shape of an existing one, for example `jsonls.lua`), `require` it from `lua/config/lsp/init.lua`, and make sure Mason installs it (append to `EcoVim.lsp.ensure_installed` in `user.lua`).
- TypeScript server choice is `EcoVim.lsp.typescript_server`. Don't wire both `ts_ls` and the alternative.
- **Formatters**: `lua/plugins/formatting.lua` (conform, `stop_after_first = true`). For personal per-filetype changes, set `EcoVim.formatters = { ft = { "tool" } }` in `user.lua`.
- **Linters**: `lua/plugins/linting.lua`.

## Verify every change

From the config root run `bash .claude/skills/nvim-config/scripts/check.sh`. It syncs plugins, does a clean headless startup, and greps `:checkhealth lazy`. Any output from the startup step means the change isn't done. That includes "Failed to source", "Error", "module … not found", and deprecation notices. If you can't run the script, run the steps manually:

```sh
nvim --headless "+Lazy! sync" +qa
nvim --headless "+qa" 2>&1             # must print nothing
nvim --headless "+checkhealth lazy" "+w! /tmp/nvim-health.txt" +qa && cat /tmp/nvim-health.txt
```

For a lazy-loaded plugin, also force it: `nvim --headless "+Lazy! load <name>" +qa 2>&1`. For an LSP change, open a matching file and run `:checkhealth vim.lsp`.

## Never

- Run a blanket `:Lazy update` or `git pull` of upstream as a side effect. Update only the plugin in question, and tell the user that `lazy-lock.json` changed.
- Add plugins the user didn't ask for. Propose them instead.
- Commit `user.lua` or `AGENTS.md`. Both are gitignored on purpose.

## Debugging startup errors

When the user pastes an error or startup prints anything, read `references/debugging.md`. It covers reading lazy.nvim tracebacks bottom-up, common error signatures, and recovering from or bisecting a bad plugin update.
