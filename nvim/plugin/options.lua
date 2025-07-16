-- See `:help vim.o`
local opt = vim.opt

-- Basic
opt.number = true          -- Line numbers
opt.relativenumber = false -- Relative line numbers
opt.cursorline = true      -- Highlight current line
opt.wrap = false           -- Don't wrap lines
opt.scrolloff = 10         -- Lines above/below cursor
opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor

-- Indentation
opt.tabstop = 2        -- Tab width
opt.shiftwidth = 2     -- Number of spaces inserted for each indentation
opt.softtabstop = 2    -- Soft tab stop
opt.expandtab = true   -- Convert tabs to spaces
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true  -- Copy indent from current line

-- Search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true  -- Case sensitive if uppercase in search
opt.hlsearch = true   -- Highlight all matches on previous search pattern
opt.incsearch = true  -- Show matches as you type

-- Appearance
opt.termguicolors = true                      -- set term gui colors (most terminals support this)
opt.signcolumn = "yes"                        -- Always show sign column, otherwise it would shift the text each time
opt.colorcolumn = "100"                       -- Show column at 100 characters
opt.showmatch = true                          -- Highlight matching brackets
opt.matchtime = 2                             -- How long to show matching bracket
opt.cmdheight = 1                             -- More space in the nvim command line for displaying messages
opt.completeopt = "menuone,noinsert,noselect" -- Completion options
opt.showmode = false                          -- Don't show mode (e.g., -- INSERT --)
opt.pumheight = 10                            -- Popup menu height
opt.pumblend = 10                             -- Popup menu transparency
opt.winblend = 0                              -- Floating window transparency
opt.conceallevel = 0                          -- Don't hide markup, so that `` is visible in markdown files
opt.concealcursor = ""                        -- Don't hide cursor line markup
opt.lazyredraw = true                         -- Don't redraw during macros
opt.synmaxcol = 300                           -- Syntax highlighting limit
opt.laststatus = 3                            -- Global status line
opt.ruler = false                             -- Don't show ruler

-- File handling
opt.backup = false                            -- Don't create backup files
opt.writebackup = false                       -- Don't create backup before writing
opt.swapfile = false                          -- Don't create swap files
opt.undofile = true                           -- Persistent undo
opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
opt.updatetime = 300                          -- Faster completion (4000ms default)
opt.timeoutlen = 500                          -- Key timeout duration, mapped sequence to complete (300ms was a bit too short)
opt.ttimeoutlen = 0                           -- Key code timeout
opt.autoread = false                          -- Don't reload files changed outside vim
opt.autowrite = false                         -- Don't auto save

-- Behavior
opt.hidden = true                   -- Allow hidden buffers
opt.errorbells = false              -- No error bells
opt.backspace = "indent,eol,start"  -- Better backspace behavior
opt.autochdir = false               -- Don't auto change directory
opt.iskeyword:append("-")           -- Treat dash as part of word
opt.path:append("**")               -- Include subdirectories in search
opt.selection = "exclusive"         -- Selection behavior
opt.mouse = "a"                     -- Enable mouse support
opt.clipboard:append("unnamedplus") -- Use system clipboard
opt.modifiable = true               -- Allow buffer modifications
opt.encoding = "utf-8"              -- Set encoding
opt.inccommand = "split"            -- Show effect of substitution command in real time
opt.splitbelow = true               -- Force all horizontal splits to go below current window
opt.splitright = true               -- Force all vertical splits to go to the right of current window



-- Disable editorconfig, not sure why this is set by default and who come up with this idea...
-- Could not figure out why my options and config under /after/ftplugin/... were not working.
-- n -V1 example.yaml
-- verbose:set shiftwidth?
-- set by ~/.local/share/nvim/runtime/lua/editorconfig.lua
-- vim.g.editorconfig = false
