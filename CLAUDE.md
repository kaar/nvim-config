# CLAUDE.md — Neovim Configuration

## Repository Overview

Personal Neovim configuration using **lazy.nvim** as the plugin manager. Targets **Neovim 0.11+** and uses the native `vim.lsp.config()` API for LSP setup. The configuration is designed to be symlinked into `~/.config/nvim`.

## Directory Structure

```
nvim-config/
├── dev.sh                        # Symlinks nvim/ → ~/.config/nvim
├── nvim/                         # Neovim config root (symlinked to ~/.config/nvim)
│   ├── init.lua                  # Entry point: leader keys, lazy.nvim bootstrap, autocommands, floating terminal
│   ├── plugin/                   # Auto-loaded by Neovim (no require needed)
│   │   ├── keymaps.lua           # Global keymaps
│   │   ├── options.lua           # Editor options (indent, search, appearance, etc.)
│   │   ├── telescope.lua         # Telescope fuzzy finder keymaps
│   │   ├── treesitter.lua        # Treesitter config and text objects
│   │   ├── psql.lua              # SQL query execution via $NVIM_PSQL_CMD
│   │   └── github.lua            # Open file on GitHub at cursor line
│   ├── lua/plugins/              # Plugin specs (each file returns a lazy.nvim spec table)
│   │   ├── lsp.lua               # LSP servers + Mason auto-install
│   │   ├── completion.lua        # nvim-cmp (config currently commented out)
│   │   ├── copilot.lua           # GitHub Copilot
│   │   ├── supermaven.lua        # Supermaven AI completion
│   │   ├── treesitter.lua        # Treesitter plugin spec
│   │   ├── telescope.lua         # Telescope plugin spec
│   │   ├── harpoon.lua           # Harpoon quick-nav marks
│   │   ├── fugitive.lua          # vim-fugitive (Git)
│   │   ├── colorschema.lua       # Gruvbox Material theme
│   │   ├── lualine.lua           # Status line
│   │   ├── autopairs.lua         # Auto-pair brackets
│   │   ├── comment.lua           # Comment toggling (gc)
│   │   ├── oil.lua               # File explorer
│   │   ├── tmux.lua              # vim-tmux-navigator
│   │   └── undotree.lua          # Undo history visualization
│   └── after/ftplugin/           # Filetype-specific overrides
│       ├── markdown.lua          # Wrap, spell, display-line navigation
│       └── html.lua              # 4-space indent, colorcolumn 120
```

## Architecture & Conventions

### Plugin Management (lazy.nvim)

- Bootstrapped in `nvim/init.lua` (auto-cloned from GitHub if missing).
- Plugin specs live in `nvim/lua/plugins/` — each file returns one or more spec tables.
- lazy.nvim auto-imports all files via `require("lazy").setup({ import = "plugins" })`.
- Change detection notifications are disabled.

### Configuration Layers

| Layer | Location | Loaded by |
|-------|----------|-----------|
| Plugin specs | `lua/plugins/*.lua` | lazy.nvim `import` |
| Plugin config / keymaps | `plugin/*.lua` | Neovim auto-load (`plugin/` dir) |
| Filetype overrides | `after/ftplugin/*.lua` | Neovim auto-load on filetype |
| Core setup + autocommands | `init.lua` | Neovim entry point |

### Adding a New Plugin

1. Create a file in `nvim/lua/plugins/` (e.g., `myplugin.lua`).
2. Return a lazy.nvim spec table: `return { "author/plugin-name", config = function() ... end }`.
3. Plugin-specific keymaps can go in the spec's `config` function or in `nvim/plugin/`.

### Adding Filetype-Specific Settings

Create `nvim/after/ftplugin/<filetype>.lua`. Settings here override globals from `plugin/options.lua`.

## Key Configuration Details

### Leader Key

**Space** is both `mapleader` and `maplocalleader` (set in both `init.lua` and `plugin/keymaps.lua`).

### Editor Defaults (`plugin/options.lua`)

- 2-space indentation (tabs expanded to spaces)
- Line numbers on, relative numbers off
- No line wrapping, color column at 100
- Case-insensitive search with smart-case
- Persistent undo (`~/.vim/undodir`), no swap/backup files
- System clipboard (`unnamedplus`)
- Global status line (`laststatus = 3`)
- Split below and right

### Important Keymaps

| Keys | Mode | Action |
|------|------|--------|
| `<leader>w` | n | Save |
| `<leader>q` | n | Quit (confirm) |
| `<leader>c` | n | Close buffer |
| `-` / `<leader>e` | n | Oil file explorer |
| `<leader>f` | n | Telescope find files |
| `<leader>st` | n | Telescope live grep |
| `<leader>/` | n | Fuzzy search current buffer |
| `<leader><space>` | n | Telescope buffers |
| `<leader>t` | n | Toggle floating terminal |
| `<leader>u` | n | Toggle UndoTree |
| `<leader>-` | n | Horizontal split |
| `<leader>\|` | n | Vertical split |
| `gd` | n | Go to definition (LSP) |
| `gr` | n | References (LSP) |
| `K` | n | Hover (LSP) |
| `<space>cr` | n | Rename (LSP) |
| `<space>ca` | n | Code action (LSP) |
| `<leader>lf` | n | Format (LSP) |
| `gh` | n | Open file on GitHub |
| `<leader>l` | n | Harpoon list |
| `<leader>m` | n | Harpoon add mark |
| `<leader>1`–`5` | n | Harpoon select 1–5 |
| `S-h` / `S-l` | n,o,x | Start / end of line |
| `A-j` / `A-k` | n,v | Move line up/down |
| `n` / `N` / `*` / `#` | n | Search with auto-center |

### LSP Servers (`lua/plugins/lsp.lua`)

Uses the **native Neovim 0.11+ `vim.lsp.config()` / `vim.lsp.enable()` API** (not mason-lspconfig's `setup_handlers`).

Configured servers: `ruff`, `pyright`, `terraformls`, `bashls`, `clangd`, `gopls`, `lua_ls`, `rust_analyzer`, `cssls`, `html`, `ts_ls`, `jsonls`, `yamlls`.

Mason auto-installs: `stylua`, `lua-language-server`, `ruff`, `clangd`, `prettier`, `bash-language-server`, `shfmt`, `terraform-ls`, `pyright`, `gopls`, `rust-analyzer`, `typescript-language-server`, `yaml-language-server`.

**Known issue:** `lua-language-server` may fail with `libbfd-2.38-system.so` not found. Workaround: `:MasonInstall lua-language-server@3.15.0`.

### Completion

nvim-cmp is installed with LSP, path, buffer, and LuaSnip sources, but the **config function is currently commented out**. AI completion is provided by Copilot and/or Supermaven.

### Treesitter

Parsers auto-installed. Ensured languages: `c`, `cpp`, `go`, `lua`, `python`, `rust`, `tsx`, `typescript`, `vimdoc`, `vim`. Text objects configured for parameters (`aa`/`ia`), functions (`af`/`if`), and classes (`ac`/`ic`).

### Autocommands (`init.lua`)

- **HighlightYank** — flash yanked text for 40ms
- **RememberCursor** — restore cursor position when reopening a file
- **TrimWhitespace** — strip trailing whitespace on save
- **NRQL filetype** — treat `*.nrql` files as SQL

### Theme

Gruvbox Material (`sainnhe/gruvbox-material`) with lualine status bar using the `gruvbox` theme.

## Development Workflow

### Setup

```sh
git clone https://github.com/kaar/nvim-config
ln -fs $PWD/nvim ~/.config/nvim
```

Or use `dev.sh` to create the symlink.

### Making Changes

1. Edit files under `nvim/`.
2. Restart Neovim or use `:Lazy reload <plugin>` for plugin changes.
3. Run `:checkhealth` to verify LSP/treesitter/provider status.
4. Run `:Lazy sync` after adding or removing plugins.

### File Naming

- Plugin specs: `nvim/lua/plugins/<descriptive-name>.lua` — note `colorschema.lua` (not `colorscheme`).
- Plugin runtime config: `nvim/plugin/<feature>.lua`.
- Filetype overrides: `nvim/after/ftplugin/<filetype>.lua`.

### Code Style

- Lua files use 2-space indentation.
- Keymaps use `vim.keymap.set` with `{ noremap = true, silent = true }` defaults.
- Strings prefer double quotes in most places, though both are used.
- Trailing whitespace is auto-stripped on save.

## Things to Know

- The `plugin/` directory is auto-loaded by Neovim — files there do not need `require()` calls.
- `<leader>e` is mapped to both Oil and NvimTreeToggle — Oil takes precedence (defined later in keymaps.lua).
- Window navigation uses `vim-tmux-navigator` (Ctrl+h/j/k/l) — native Vim window nav keymaps are commented out.
- The floating terminal (`<leader>t`) auto-closes on BufLeave and toggles on repeated press.
- Semantic tokens are disabled for Lua files in the LSP config.
- The `psql.lua` plugin expects `NVIM_PSQL_CMD` environment variable to be set for SQL execution.
