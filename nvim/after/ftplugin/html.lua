-- HTML-specific settings
local opt = vim.opt_local

-- Indentation (4 spaces for HTML)
opt.tabstop = 4        -- Tab width
opt.shiftwidth = 4     -- Number of spaces for each indentation
opt.softtabstop = 4    -- Soft tab stop
opt.expandtab = true   -- Convert tabs to spaces

-- Line wrapping
opt.wrap = false       -- Don't wrap lines by default
opt.textwidth = 0      -- Don't auto-insert line breaks
opt.colorcolumn = "120" -- Show column at 120 characters for reference

-- HTML specific
opt.matchpairs:append("<:>") -- Add angle brackets to matchpairs

