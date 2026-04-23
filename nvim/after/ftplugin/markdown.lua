-- Markdown fenced code block syntax highlighting
--
-- Neovim 0.12 bundles the Tree-sitter engine and a small set of parsers:
-- c, lua, markdown, markdown_inline, query, vim, vimdoc.
--
-- Markdown highlighting itself works out of the box. However, syntax
-- highlighting inside fenced code blocks (e.g. ```python) requires the
-- parser for each embedded language to be present as a .so file on
-- Neovim's runtimepath (specifically in a parser/ directory).
--
-- Homebrew's tree-sitter-* formulae install .dylib files, which Neovim
-- cannot use. Parsers must be compiled as .so files using the
-- tree-sitter CLI and placed in ~/.local/share/nvim/site/parser/.
--
-- To add a language:
--   cd $(brew --prefix tree-sitter-<lang>)/share/tree-sitter/<lang>
--   tree-sitter build --output ~/.local/share/nvim/site/parser/<lang>.so
--
-- Parsers installed this way:
--   python: tree-sitter-python (brew)
--   bash:   tree-sitter-bash (brew)
-- Markdown-specific settings
local opt = vim.opt_local

opt.wrap = true      -- Wrap lines at the end of the screen
opt.linebreak = true -- Break at word boundaries
opt.textwidth = 0    -- Don't auto-insert line breaks

-- Better navigation with wrapped lines
-- Moving by display lines instead of physical lines
vim.keymap.set({ "n", "v" }, "j", "gj", { buffer = true, desc = "Move down by display line" })
vim.keymap.set({ "n", "v" }, "k", "gk", { buffer = true, desc = "Move up by display line" })
vim.keymap.set({ "n", "v" }, "0", "g0", { buffer = true, desc = "Go to start of display line" })
vim.keymap.set({ "n", "v" }, "$", "g$", { buffer = true, desc = "Go to end of display line" })

-- Spell checking
opt.spell = true
opt.spelllang = "en_us"

-- Wikilink support for gf ([[entities/forefront]] -> entities/forefront.md)
opt.suffixesadd:append(".md")
vim.opt_local.includeexpr = "v:lua.resolve_wikilink(v:fname)"

function _G.resolve_wikilink(fname)
  -- Strip [[ and ]] if present
  return fname:gsub("%[%[", ""):gsub("%]%]", "")
end
