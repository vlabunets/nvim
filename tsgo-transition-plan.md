# tsgo transition plan

Plan for switching the TypeScript server from `ts_ls` to tsgo (the native TypeScript 7 language server).
Status: **deferred.** Staying on `ts_ls` until the steps below are done. Findings are from 2026-11-16.

## Why switch

- tsgo is the TypeScript 7 compiler's own language server. TypeScript 7 no longer ships the JavaScript
  `tsserver` that `ts_ls` (and vtsls) run on, so `ts_ls` falls back to an older bundled TypeScript in
  projects on TypeScript 7.
- On a ~2,000-file Angular app it loaded the project in 0.8s instead of 5.8s, and type-checked the app
  in 0.8s instead of 3.8s, with the same hover, go-to-definition, references and inlay hint results.

vtsls was considered and rejected: last release 0.3.0 (December 2025), and it runs on `tsserver` too.

## Check a project before switching

### 1. `baseUrl` in tsconfig

TypeScript 7 removed `baseUrl`. Imports that only resolve through it (bare paths like
`from 'src/app/...'`) break: tsgo reports "Cannot find module" (TS2307) on them and has no types for
those symbols, and `tsc` 7 stops with TS5102 / TS5090.

Find them: `grep -rE "from ['\"]src/" src --include='*.ts'`

Fix in `tsconfig.json` (works with TypeScript 6 too):

```diff
   "compilerOptions": {
-    "baseUrl": "./",
-    "ignoreDeprecations": "6.0",
     ...
     "paths": {
-      "@core/*": ["src/app/core/*"],
+      "*": ["./*"],
+      "@core/*": ["./src/app/core/*"],
       ... same "./" prefix for every other alias ...
     }
```

After the change, check the TypeScript 6 build still passes: `npx tsc -p tsconfig.app.json --noEmit`.

### 2. Errors that only TypeScript 7 reports

Type-check with TypeScript 7 next to the project's own version and compare:
`npx -p typescript@7 tsc -p tsconfig.app.json --noEmit`.

Seen so far: an overload error (TS2769, "No overload matches this call") reported on a different line
of a multi-line call than TypeScript 6 reports it, so a `// @ts-expect-error` placed for TypeScript 6
no longer covers it. Move the comment, or fix the typing.

## What tsgo doesn't do (accepted trade-offs)

- No source actions for add missing imports, fix all, and remove unused, so these mappings do nothing
  under tsgo: `<leader>ci`, `<leader>cF`, `<leader>cu`. Organize imports, remove unused imports and sort
  imports work.
- Renaming a folder doesn't update imports (renaming files does, via the snacks explorer and yazi).
- No `workspace/executeCommand` (`ts_ls` uses commands for a few TypeScript-specific actions).
- Vue: `vue_ls` needs `@vue/typescript-plugin`, which tsgo can't load. Keep `ts_ls` for Vue projects.
- Angular templates are unaffected: `angularls` is a separate server using the project's own TypeScript.

## Migration steps

1. Fix the project (sections 1 and 2 above).
2. Install the released TypeScript 7 globally: `npm i -g typescript@7`.
   - lspconfig's `tsc` config uses a `tsc`/`tsgo` that supports `--lsp`: first `node_modules/.bin`
     (skipped while the project is on TypeScript 6), then `PATH`. Without a TypeScript 7 binary on
     either, the server doesn't start.
   - Don't use Mason's `tsgo` package: it installs `@typescript/native-preview` 7.0.0-dev.20260707, a
     preview older than the TypeScript 7.0.2 release.
3. In `lua/config/user.lua`: `Nvim.lsp.typescript_server = "tsgo"` (enables lspconfig's `tsc` config,
   see `lua/plugins/lsp.lua` and `lua/config/lsp/servers/tsc.lua`).
4. Verify in the project: open a file that used a bare `baseUrl` import and check there are no TS2307
   errors, hover shows types, go-to-definition and references work, and `:checkhealth vim.lsp` shows
   `tsc` attached (and not `ts_ls`).
5. Decide what to do with `<leader>ci`, `<leader>cF`, `<leader>cu` (hide them under tsgo, or map them to
   alternatives such as ESLint fixes).

## Rollback

Set `Nvim.lsp.typescript_server = "ts_ls"` in `user.lua` and restart Neovim.
