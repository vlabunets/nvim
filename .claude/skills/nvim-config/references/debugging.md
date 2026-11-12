# Debugging Neovim startup errors

## Reading a lazy.nvim traceback

Read the `stack traceback:` **bottom-up** to see how loading got there, then find the **topmost frame inside a plugin's own `lua/` or `plugin/` directory** — that's the real failure point. Frames in `lazy.nvim/lua/lazy/core/*` are just the loader.

Example:
```
...lazy/avante.nvim/lua/avante/commands.lua:146: in function 'setup'   <- real failure
...lazy/avante.nvim/plugin/avante.lua:21: in main chunk
...lazy/lazy.nvim/lua/lazy/core/loader.lua:510: ...                    <- loader noise
/Users/.../.config/nvim/lua/config/lazy.lua:25: in main chunk          <- your setup() call
```

Open the failing line to see what it expects: `sed -n '140,150p' ~/.local/share/nvim/lazy/<plugin>/lua/<path>.lua` (read only — never edit there).

## Common error signatures

| Message | Meaning | Fix |
|---|---|---|
| `module 'x.y' not found` + list of `no file '...'` | A Lua dependency isn't installed/on runtimepath | Find the repo providing `x.y` (check the plugin's README / `*.rockspec` / `lazy.lua`) and add it to `dependencies` |
| Paths containing `lazy-rocks/<plugin>/` in that list | Plugin ships a rockspec, but `rocks.enabled = false` in this config | Read the plugin's `*.rockspec` for its deps and add each as a plain plugin in `dependencies` |
| `attempt to call field 'setup' (a nil value)` | Wrong `main` module, or `opts` used on a plugin without `setup` | Set `main = "module"` or use `config = function() ... end` |
| `attempt to index a nil value` inside your config | Called `require("x")` before `x` loaded (lazy-loading race) | Move code into the plugin's `config`/`init`, or add the plugin to `dependencies` |
| `E5108` / `E5113` | Lua error during a `:lua` call / while sourcing | Same as above — locate the topmost user/plugin frame |
| `... is deprecated` | Plugin or Neovim API change | Update the call to the suggested replacement; check `:h deprecated` |
| `Invalid buffer id` / `Invalid window id` in autocmds | Callback runs after buffer/window closed | Guard with `vim.api.nvim_buf_is_valid` / `nvim_win_is_valid` |

## When a plugin update broke startup

1. Confirm which plugin: `git -C ~/.config/nvim diff lazy-lock.json`.
2. Quick recovery: `:Lazy restore <name>` (restores the lockfile commit), or `git checkout lazy-lock.json` then `nvim --headless "+Lazy! restore" +qa`.
3. To stay on the old version, set `commit = "<sha>"` in the spec temporarily.
4. Look upstream (repo issues / recent commits) for a new required dependency or renamed option, then fix the spec and remove the pin.

## Bisecting "something broke" with no clear plugin

```sh
nvim --clean                          # vanilla Neovim — does the problem persist?
nvim -u NONE                          # no config at all
nvim --startuptime /tmp/st.log +qa    # slow startup: sort by the 2nd column
```

Disable halves of `lua/plugins/` by adding `enabled = false` to specs (or temporarily renaming files to `*.lua.off`) until the culprit is isolated. Restore everything afterwards.

## Useful in-editor commands

- `:Lazy` → `L` to view the log, `P` for profiling.
- `:messages` — full text of truncated notifications.
- `:checkhealth` / `:checkhealth <plugin>`.
- `:lua =package.loaded["x"]` — is a module loaded?
- `:lua =vim.api.nvim_get_runtime_file("lua/x/y.lua", true)` — is a file on runtimepath?
