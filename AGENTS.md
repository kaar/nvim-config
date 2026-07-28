Personal Neovim config, targeting **Neovim 0.12+**.

## Layout

```
nvim/
├── init.lua              # leader, plugins, LSP, plugin setup (Copilot, Harpoon, Oil, …), autocmds
├── plugin/*.lua          # auto-sourced at startup (one file per concern)
├── after/ftplugin/*.lua  # auto-sourced per filetype (buffer-local only)
├── ftdetect/*.lua        # filetype detection
├── stylua.toml           # 2-space indent, no_call_parentheses
└── nvim-pack-lock.json   # vim.pack lockfile (committed, not ignored)
```

No `lua/` directory. File location determines when code runs — add a new feature as `plugin/<name>.lua`, not by requiring from `init.lua`. Each `plugin/` file is named after its concern (`keymaps`, `options`, `telescope`, `terminal`, …); plugin `setup()` calls that must run in a known order stay in `init.lua`.

## Install

```sh
ln -s "$PWD"/nvim ~/.config/nvim
```

No build or test step. Reload by restarting Neovim or `:source`-ing the changed file.

Verify a change headlessly — startup errors print to stderr, silence means the config loads:

```sh
nvim --headless "+lua print('ok')" +q
```

Format Lua with `stylua`; check with `stylua --check nvim/`.

## Package manager — `vim.pack` (built-in)

Plugins are declared in the `vim.pack.add{ ... }` call in `init.lua` as git URLs. **Do not** introduce lazy.nvim, packer, etc. Pin with `{ src = "...", version = "..." }`. Commit `nvim-pack-lock.json` when versions change.

Plugins on disk that are not in that spec get auto-deleted as orphans on startup (`init.lua`). Every plugin must therefore be added unconditionally in the single `vim.pack.add` call — a lazily `:packadd`-ed plugin looks inactive right after startup and would be wrongly deleted.

## LSP — native API (no `lspconfig.setup`)

- `vim.lsp.enable{ ... }` enables servers.
- `vim.lsp.config('<server>', { settings = ... })` overrides settings.
- `mason-lspconfig` runs with `automatic_enable = false`; enabling is explicit.
- Buffer-local keymaps live in one `LspAttach` autocmd in `init.lua`. `gd` is the Telescope picker; `gD` keeps the built-in.

## Conventions

- Leader and localleader: `<Space>`.
- Diagnostics: `virtual_lines`.
- Autocmds in `init.lua` trim trailing whitespace on save, restore cursor on read, highlight yanks.

## Gotchas

- **Markdown wikilinks** (`after/ftplugin/markdown.lua`): `_G.resolve_wikilink` + `suffixesadd=.md` makes `gf` open `[[entities/foo]]`. Known bug: `@` in paths gets stripped by `gf` (see `TODO.md`).
- **Tree-sitter parsers** are managed by nvim-treesitter (main branch) via `plugin/treesitter.lua` — add languages to its install list and run `:TSInstall`. Requires `tree-sitter-cli`, curl, tar and a C compiler; no manual `.so` builds.
- **Floating terminal** (`plugin/terminal.lua`): `<leader>t` toggles, `<Esc><Esc>` closes; buffer is reused.
