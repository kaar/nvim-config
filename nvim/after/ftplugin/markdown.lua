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

