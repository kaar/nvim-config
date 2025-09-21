vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)
keymap("n", "<leader>q", "<cmd>confirm q<CR>", opts)
keymap("n", "<leader>w", "<cmd>w!<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
keymap("n", "<leader>c", ":bd<CR>", { desc = "Close buffer", silent = true })

-- Oil, https://github.com/stevearc/oil.nvim
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Oil, Open parent directory" })
keymap("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Oil, Open parent directory" })
-- keymap('n', '<leader>e', require("oil").toggle_float)

-- Better window navigation
-- Using vim-tmux-navigator
-- keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
-- keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
-- keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
-- keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Switch to the last accessed window
keymap("n", "<m-tab>", "<c-6>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move current line / block with Alt-j/k
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv-gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv-gv", opts)

-- Use s-h/l for beginning/end of line
keymap({ "n", "o", "x" }, "<s-h>", "^", { desc = "Go to start of line" })
keymap({ "n", "o", "x" }, "<s-l>", "g_", { desc = "Go to end of line" })

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Maintaining the content of the default register intact while pasting
-- over a selection in visual mode.
keymap("x", "p", [["_dP]])

-- Split navigation like I do in tmux
keymap("n", "<leader>-", "<C-w>s", opts)
keymap("n", "<leader>|", "<C-w>v", opts)

-- Execute `q` command in a new split
keymap("n", "<leader>x", ":new tmp.md | read !q #<CR>", opts)

-- Enhance the default search navigation by ensuring that the screen is
-- centered on each match
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "*", "*zz", opts)
keymap("n", "#", "#zz", opts)
keymap("n", "g*", "g*zz", opts)
keymap("n", "g#", "g#zz", opts)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
keymap({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- UndoTree
keymap("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Man page for word under cursor
keymap("n", "<leader>K", ":Man <C-r><C-w><CR>", { desc = "Open man page for word under cursor" })
