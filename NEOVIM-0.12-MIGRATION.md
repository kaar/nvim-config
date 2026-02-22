# Neovim 0.12 Migration Guide

> **Status:** Neovim 0.12 is in active development (nightly). The latest stable
> release is **0.11.6** (January 2026). The 0.12 milestone is ~83% complete with
> a target date of **March 14, 2026**.

This guide covers what changes when migrating this config from Neovim 0.11 to
0.12, which plugins can be replaced by built-in features, and what breaking
changes to watch out for.

---

## Table of Contents

1. [Breaking Changes That Affect This Config](#1-breaking-changes-that-affect-this-config)
2. [Plugins You Can Drop](#2-plugins-you-can-drop)
3. [Built-in Plugin Manager: `vim.pack`](#3-built-in-plugin-manager-vimpack)
4. [Built-in Completion: Replace nvim-cmp](#4-built-in-completion-replace-nvim-cmp)
5. [Native Copilot: `vim.lsp.inline_completion`](#5-native-copilot-vimlspinline_completion)
6. [LSP Improvements](#6-lsp-improvements)
7. [New Built-in Commands](#7-new-built-in-commands)
8. [New Options Worth Exploring](#8-new-options-worth-exploring)
9. [Treesitter Changes](#9-treesitter-changes)
10. [Deprecated APIs to Stop Using](#10-deprecated-apis-to-stop-using)
11. [Step-by-Step Migration Checklist](#11-step-by-step-migration-checklist)

---

## 1. Breaking Changes That Affect This Config

These are changes in 0.12 that will break or affect the current config.

### `vim.diff` renamed to `vim.text.diff`

Not used directly in this config, but worth knowing. Any `vim.diff()` calls
must become `vim.text.diff()`.

### `vim.diagnostic.disable()` and `vim.diagnostic.is_disabled()` removed

These were deprecated in 0.10 and are now gone. Use instead:

```lua
-- Disable diagnostics
vim.diagnostic.enable(false)

-- Check if disabled
-- vim.diagnostic.is_disabled() → no direct replacement, use vim.diagnostic.is_enabled()
```

Not used in this config, but be aware if adding diagnostic toggles.

### `'shelltemp'` defaults to `false`

Shell commands now use pipes instead of temp files by default. This is
generally transparent but could affect `psql.lua` if the SQL execution relies
on temp file behavior. Test the `QuerySelection()` function after upgrading.

### `i_CTRL-R` behavior changed

Insert-mode `<C-r>` now inserts registers literally (like paste) instead of as
typed input. To get the old behavior: `<C-R>=@x`. This affects anyone who uses
`<C-r>` to insert registers in insert mode.

### Diagnostic signs no longer configurable via `:sign-define`

If you ever configure diagnostic signs with `vim.fn.sign_define()`, that no
longer works. Use `vim.diagnostic.config({ signs = { ... } })` instead. This
config doesn't currently set custom signs, so no action needed.

### `'exrc'` trust flow changed

`:exrc` no longer shows an "(a)llow" option — you must "(v)iew" the file first
then run `:trust`. Not directly relevant unless you use project-local configs.

---

## 2. Plugins You Can Drop

### Comment.nvim → built-in `gc` (since 0.10)

**File:** `lua/plugins/comment.lua`

Neovim 0.10 added built-in commenting via `gc` (line) and `gc` in visual mode.
This is identical to what Comment.nvim provides with default settings.

**Action:** Delete `nvim/lua/plugins/comment.lua`. The built-in `gc`/`gcc`
works out of the box.

```lua
-- DELETE: nvim/lua/plugins/comment.lua
-- "gc" to comment visual regions/lines
-- return { "numToStr/Comment.nvim", opts = {} }
```

### undotree → built-in `:Undotree` (0.12)

**File:** `lua/plugins/undotree.lua`

Neovim 0.12 includes a built-in `:Undotree` command.

**Action:** Delete `nvim/lua/plugins/undotree.lua` and update the keymap in
`plugin/keymaps.lua`:

```lua
-- Before (plugin):
keymap("n", "<leader>u", vim.cmd.UndotreeToggle)

-- After (built-in):
keymap("n", "<leader>u", "<cmd>Undotree<CR>", opts)
```

### copilot.lua / supermaven → `vim.lsp.inline_completion` (0.12)

**Files:** `lua/plugins/copilot.lua`, `lua/plugins/supermaven.lua`

Neovim 0.12 adds native `textDocument/inlineCompletion` support (LSP 3.18).
You can use `copilot-language-server` directly as an LSP server — no plugin
needed. See [section 5](#5-native-copilot-vimlspinline_completion) for full
setup.

### nvim-cmp → `vim.lsp.completion` (0.11+, improved in 0.12)

**File:** `lua/plugins/completion.lua` (already commented out)

The config is already commented out. Neovim 0.12 adds `'autocomplete'` option
and `'pumborder'`/`'pummaxwidth'` for better built-in completion. See
[section 4](#4-built-in-completion-replace-nvim-cmp).

---

## 3. Built-in Plugin Manager: `vim.pack`

Neovim 0.12 introduces `vim.pack` — a built-in plugin manager. This is the
headline feature and could replace lazy.nvim.

### How `vim.pack` works

- Manages plugins in `$XDG_DATA_HOME/nvim/site/pack/core/opt`
- Uses Git to clone/update plugins
- Lockfile at `$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json`
- Plugins are loaded immediately (no lazy loading)

### API

```lua
-- Install plugins
vim.pack.add({
  'https://github.com/sainnhe/gruvbox-material',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/tpope/vim-fugitive',
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
})

-- Update all plugins
vim.pack.update()

-- Remove a plugin from disk
vim.pack.del('gruvbox-material')

-- Get plugin info
vim.pack.get('oil.nvim')
```

### Git shorthand trick

Add to your global gitconfig for shorter URLs:

```bash
git config --global url."https://github.com/".insteadOf "gh:"
```

Then you can write:

```lua
vim.pack.add({
  'gh:sainnhe/gruvbox-material',
  'gh:stevearc/oil.nvim',
  'gh:tpope/vim-fugitive',
})
```

### Should you switch from lazy.nvim?

**Pros of `vim.pack`:**
- Zero dependencies — built into Neovim
- Simpler mental model — no spec tables, no lazy-loading DSL
- Lockfile support for reproducible installs
- `PackChanged` / `PackChangedPre` autocommand events

**Cons of `vim.pack`:**
- **No lazy loading** — all plugins load at startup
- No build steps (lazy.nvim runs `build = "make"`, `build = ":TSUpdate"`, etc.)
- No `config` functions — you must configure plugins separately
- No conditional loading (`cond`, `event`, `cmd`, `ft`)
- No automatic UI dashboard

**Verdict for this config:** This config has ~15 plugins. Without lazy loading,
startup will be slightly slower but likely still under 100ms. The main pain
point is plugins that need build steps:

| Plugin | Needs build step? |
|--------|------------------|
| telescope-fzf-native | Yes (`make`) |
| nvim-treesitter | Yes (`:TSUpdate`) |
| LuaSnip | Yes (`make install_jsregexp`) |

For build steps, you'd need to run them manually or use the `PackChanged`
autocommand:

```lua
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    if name == "telescope-fzf-native.nvim" then
      vim.fn.system("make -C " .. ev.data.spec.path)
    end
  end,
})
```

### Example: Full config with `vim.pack`

Here's what your `init.lua` would look like rewritten for `vim.pack`:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install plugins (vim.pack.add is idempotent — only clones if missing)
vim.pack.add({
  -- Theme
  "https://github.com/sainnhe/gruvbox-material",

  -- UI
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/stevearc/oil.nvim",

  -- Navigation
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  "https://github.com/christoomey/vim-tmux-navigator",

  -- Editing
  "https://github.com/windwp/nvim-autopairs",

  -- Git
  "https://github.com/tpope/vim-fugitive",

  -- Treesitter
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",

  -- LSP
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/folke/neodev.nvim",
})

-- Handle build steps after install/update
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    local path = ev.data.spec.path
    if name == "telescope-fzf-native.nvim" then
      vim.fn.system("make -C " .. path)
    elseif name == "nvim-treesitter" then
      vim.cmd("TSUpdate")
    end
  end,
})

-- Plugin configuration (each plugin configured after vim.pack.add)
vim.cmd.colorscheme("gruvbox-material")

require("lualine").setup({
  options = {
    icons_enabled = false,
    theme = "gruvbox",
    component_separators = "|",
    section_separators = "",
  },
})

require("oil").setup({
  columns = { "icon" },
  view_options = { show_hidden = true },
  default_file_explorer = true,
})

require("nvim-autopairs").setup({})

local harpoon = require("harpoon")
harpoon:setup()
-- ... harpoon keymaps ...

-- ... rest of config (autocommands, keymaps, etc.)
```

### Hybrid approach: `vim.pack` + lazy loading wrapper

Community plugins like `zpack.nvim` add lazy-loading on top of `vim.pack` if
you want the best of both worlds. The `mini.deps` project (part of mini.nvim)
is also planning to retire in favor of `vim.pack` once 0.12 releases.

---

## 4. Built-in Completion: Replace nvim-cmp

Your nvim-cmp config is already commented out. Neovim 0.12 makes the built-in
completion viable as a full replacement.

### Setup

```lua
-- In your LspAttach autocommand or after LSP is configured:
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, {
        autotrigger = true,
      })
    end
    -- ... your other LSP keymaps ...
  end,
})
```

### New 0.12 options for completion UI

```lua
-- Auto-trigger completion as you type (new in 0.12)
vim.opt.autocomplete = "."

-- Popup menu border
vim.opt.pumborder = true

-- Max width for completion popup
vim.opt.pummaxwidth = 40

-- Already set in your config:
vim.opt.pumheight = 10
vim.opt.pumblend = 10
```

### What you lose vs nvim-cmp

- No path/buffer/snippet completion sources (LSP-only)
- No custom sorting/filtering logic
- No per-filetype source configuration
- Snippet expansion is more basic

For a config that already has Copilot/Supermaven doing most of the heavy
lifting, the built-in completion is often sufficient.

---

## 5. Native Copilot: `vim.lsp.inline_completion`

This is one of the most interesting 0.12 features. You can use GitHub Copilot
(or any inline-completion LSP) natively without any plugin.

### Install copilot-language-server

```bash
npm install -g copilot-language-server
```

Or add it to Mason's `ensure_installed`.

### Configure as LSP server

Add to your `servers` table in `lua/plugins/lsp.lua` (or wherever LSP is
configured in a vim.pack world):

```lua
-- In your LSP configuration:
vim.lsp.config("copilot_ls", {
  cmd = { "copilot-language-server", "--stdio" },
  filetypes = {
    "python", "lua", "go", "rust", "c", "cpp",
    "typescript", "javascript", "typescriptreact",
    "html", "css", "yaml", "json", "markdown",
    "sh", "bash", "terraform",
  },
  root_markers = { ".git" },
  init_options = {
    copilot = {
      openAICompatible = {
        -- Leave empty for default GitHub Copilot
      },
    },
  },
})
vim.lsp.enable("copilot_ls")
```

### Enable inline completion

```lua
-- Enable the inline completion UI
vim.lsp.inline_completion.enable()

-- Keymaps (in insert mode)
vim.keymap.set("i", "<C-e>", function()
  local ic = vim.lsp.inline_completion
  if ic.is_visible() then
    ic.accept()
  end
end, { desc = "Accept inline completion" })

vim.keymap.set("i", "<A-]>", function()
  vim.lsp.inline_completion.get()
end, { desc = "Trigger inline completion" })

vim.keymap.set("i", "<C-]>", function()
  vim.lsp.inline_completion.dismiss()
end, { desc = "Dismiss inline completion" })
```

### What this replaces

- `lua/plugins/copilot.lua` — delete entirely
- `lua/plugins/supermaven.lua` — delete entirely (or keep if you prefer
  Supermaven's model, though it won't use the native inline completion API
  unless it ships an LSP server)

### Authentication

You'll still need to authenticate with Copilot. On first use, you'll be
prompted in Neovim or you can run:

```bash
copilot-language-server --stdio
```

and follow the device flow authentication.

---

## 6. LSP Improvements

### New `:lsp` ex commands

Replaces what nvim-lspconfig provided:

```
:lsp enable lua_ls        " Start a specific server
:lsp disable lua_ls       " Stop and disable a server
:lsp restart lua_ls       " Restart a server
:lsp stop lua_ls          " Stop without disabling
```

### `vim.lsp.is_enabled()`

New helper to check if a config is enabled:

```lua
if vim.lsp.is_enabled("lua_ls") then
  -- ...
end
```

### Nested `root_markers` with priority

You can now express marker priority:

```lua
vim.lsp.config("lua_ls", {
  root_markers = {
    { ".luarc.json", ".luarc.jsonc" },  -- highest priority (equal within group)
    ".stylua.toml",                       -- next priority
    ".git",                               -- fallback
  },
})
```

### New default keymap: `grt`

`grt` in normal mode now maps to `vim.lsp.buf.type_definition()` by default.
Your current config maps this to `gT` — you may want to keep yours or adopt
the new default.

### New default keymaps: `an`/`in` incremental selection

Visual/operator-pending mode `an`/`in` now maps to LSP `selectionRange`. This
overlaps with your treesitter incremental selection (`<C-space>`) — both can
coexist.

### `gx` now uses `textDocument/documentLink`

The built-in `gx` (open URL under cursor) will use LSP document links if
available. This gives you smarter link-following in supported languages.

### Better `vim.lsp.buf.rename()`

Rename now highlights the symbol with `LspReferenceTarget` during the rename
prompt, making it easier to see what you're renaming.

---

## 7. New Built-in Commands

### `:DiffTool`

A built-in diff tool for comparing directories and files:

```vim
:packadd nvim.difftool    " Load first (not loaded by default)
:DiffTool dir_a/ dir_b/
:DiffTool file_a file_b
```

This was in your `init.lua` TODO list (`diffview.nvim`). The built-in version
covers the basic use case.

### `:Undotree`

Built-in undo tree visualization — replaces `mbbill/undotree`.

### `:restart`

Restarts Neovim and reattaches the UI. Useful for config development — faster
than quitting and reopening.

### `:iput`

Like `:put` but adjusts indentation automatically.

### `:uniq`

Deduplicates lines in the buffer.

### `:retab -indentonly`

Retab only leading whitespace, leaving strings and comments alone.

---

## 8. New Options Worth Exploring

### `'autocomplete'`

Enables automatic completion popup as you type:

```lua
vim.opt.autocomplete = "."  -- trigger on any character
```

### `'pumborder'`

Adds a border to the completion popup:

```lua
vim.opt.pumborder = true
```

### `'pummaxwidth'`

Sets maximum width for the completion popup:

```lua
vim.opt.pummaxwidth = 50
```

### `'winborder'` — "bold" style

The `'winborder'` option now supports "bold" borders. Your floating terminal
uses `border = "rounded"` which still works.

### `'maxsearchcount'`

Defaults to 999. Controls the maximum count shown with `[N/M]` search display.

### `'busy'`

Sets buffer busy status — shown in statusline with a spinner. Useful for
long-running operations.

### `'diffanchors'`

For diff mode — lets you specify anchor addresses that must appear in the same
position in both files.

---

## 9. Treesitter Changes

### Markdown highlighting enabled by default

Neovim 0.12 enables treesitter highlighting for Markdown by default. Your
`after/ftplugin/markdown.lua` should still work fine alongside this.

### `vim.treesitter.get_parser()` returns nil instead of erroring

The default behavior changes — `get_parser()` returns `nil` when no parser is
found instead of throwing. This is safer but means any code checking the return
value should handle `nil`.

### Query lint no longer auto-enabled

`vim.treesitter.query.lint()` is no longer enabled by default for query files.
Not relevant to this config.

### `LanguageTree:for_each_child()` deprecated

Use `LanguageTree:children()` instead. Not used directly in this config.

---

## 10. Deprecated APIs to Stop Using

These are newly deprecated in 0.12. They still work but will be removed in a
future version. Avoid using them in new code.

### LSP deprecations

| Deprecated | Replacement |
|-----------|-------------|
| `vim.lsp.set_log_level()` | `vim.lsp.log.set_level()` |
| `vim.lsp.get_log_path()` | `vim.lsp.log.get_filename()` |
| `vim.lsp.stop_client()` | `Client:stop()` |
| `vim.lsp.get_buffers_by_client_id()` | `client.attached_buffers` |
| `vim.lsp.buf.execute_command()` | `Client:exec_cmd()` |
| `vim.lsp.buf.completion()` | `vim.lsp.completion.get()` |
| `vim.lsp.client_is_stopped()` | `vim.lsp.get_client_by_id()` |
| `vim.lsp.semantic_tokens.start()` | `vim.lsp.semantic_tokens.enable(true)` |
| `vim.lsp.semantic_tokens.stop()` | `vim.lsp.semantic_tokens.enable(false)` |
| `vim.lsp.codelens.refresh()` | `vim.lsp.codelens.enable(true)` |
| `vim.lsp.codelens.clear()` | `vim.lsp.codelens.enable(false)` |
| `vim.lsp.util.jump_to_location()` | `vim.lsp.util.show_document({focus=true})` |

### Diagnostic deprecations

| Deprecated | Replacement |
|-----------|-------------|
| `"float"` in `JumpOpts` | `"on_jump"` |
| `vim.diagnostic.get_next_pos()` | `.lnum` / `.col` from `get_next()` |
| `vim.diagnostic.get_prev_pos()` | `.lnum` / `.col` from `get_prev()` |
| `"win_id"` parameter | `"winid"` |

### Other

| Deprecated | Replacement |
|-----------|-------------|
| `vim.diff()` | `vim.text.diff()` |
| `:ownsyntax` | `'winhighlight'` |

---

## 11. Step-by-Step Migration Checklist

### Phase 1: Safe changes (no behavior change)

- [ ] Delete `nvim/lua/plugins/comment.lua` — built-in `gc` since 0.10
- [ ] Test that `gc`/`gcc` commenting works without the plugin

### Phase 2: Replace undotree

- [ ] Delete `nvim/lua/plugins/undotree.lua`
- [ ] Update keymap in `nvim/plugin/keymaps.lua`:
  ```lua
  keymap("n", "<leader>u", "<cmd>Undotree<CR>", opts)
  ```
- [ ] Test `:Undotree` command works

### Phase 3: Native completion

- [ ] Delete `nvim/lua/plugins/completion.lua` (or keep deps for LSP
  capabilities)
- [ ] Add to your LspAttach callback:
  ```lua
  if client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, args.buf, {
      autotrigger = true,
    })
  end
  ```
- [ ] Set new options in `plugin/options.lua`:
  ```lua
  opt.pumborder = true
  opt.pummaxwidth = 40
  ```
- [ ] Test completion in various filetypes

### Phase 4: Native Copilot

- [ ] Install `copilot-language-server` (`npm install -g copilot-language-server`)
- [ ] Add `copilot_ls` to LSP server config (see section 5)
- [ ] Add `vim.lsp.inline_completion.enable()` and keymaps
- [ ] Delete `nvim/lua/plugins/copilot.lua`
- [ ] Delete `nvim/lua/plugins/supermaven.lua`
- [ ] Test Copilot suggestions appear and `<C-e>` accepts

### Phase 5: Consider `vim.pack` (optional, bigger change)

- [ ] Rewrite `init.lua` to use `vim.pack.add()` instead of lazy.nvim bootstrap
- [ ] Move plugin configs from lazy spec `config` functions to standalone
  `require().setup()` calls
- [ ] Handle build steps via `PackChanged` autocommand
- [ ] Delete `nvim/lua/plugins/` directory (specs no longer needed)
- [ ] Test startup time — compare with `nvim --startuptime`
- [ ] If startup is too slow, consider `zpack.nvim` for lazy loading on top

### Phase 6: Explore new features

- [ ] Try `:DiffTool` for directory diffs (was a TODO in init.lua)
- [ ] Try `:restart` for faster config iteration
- [ ] Try nested `root_markers` for priority ordering in LSP configs
- [ ] Experiment with `vim.net.request()` for HTTP requests in plugins
- [ ] Try the new `'busy'` option for long-running buffer operations

---

## Sources

- [Neovim 0.12 News (master)](https://neovim.io/doc/user/news.html)
- [Neovim 0.12 Deprecated APIs](https://neovim.io/doc/user/deprecated.html)
- [Neovim 0.12 Milestone](https://github.com/neovim/neovim/milestone/43)
- [Neovim 0.12 Release Checklist (#33066)](https://github.com/neovim/neovim/issues/33066)
- [Neovim Roadmap](https://neovim.io/roadmap/)
- [vim.pack documentation](https://neovim.io/doc/user/pack.html)
- [vim.pack blog post (briandouglas.ie)](https://briandouglas.ie/vim-dot-pack/)
- [Built-in plugin manager guide (bower.sh)](https://bower.sh/nvim-builtin-plugin-mgr)
- [Native LSP setup for 0.12 (tduyng.com)](https://tduyng.com/blog/neovim-basic-setup/)
- [Inline completion PR (#33972)](https://github.com/neovim/neovim/pull/33972)
- [copilot-lsp plugin](https://github.com/copilotlsp-nvim/copilot-lsp)
- [mini.nvim retiring mini.deps for vim.pack](https://nvim-mini.org/blog/2026-02-15-update-minimax-configs-012-010.html)
