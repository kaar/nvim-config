-- Markdown fenced code block syntax highlighting
--
-- Highlighting (including injections into ```py / ```bash etc. fenced blocks)
-- is handled by Neovim's tree-sitter engine, started via the FileType autocmd
-- in plugin/treesitter.lua. Each embedded language just needs its parser
-- installed; add languages to the install list there and run :TSInstall.

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
