vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)
keymap("n", "<leader>q", "<cmd>confirm q<CR>", opts)
keymap("n", "<leader>w", "<cmd>w!<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Oil, https://github.com/stevearc/oil.nvim
keymap("n", "-", "<CMD>Oil<CR>", { desc = "Oil, Open parent directory" })
keymap("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Oil, Open parent directory" })
-- keymap('n', '<leader>e', require("oil").toggle_float)

-- Better window navigation
keymap("n", "<m-h>", "<C-w>h", opts)
keymap("n", "<m-j>", "<C-w>j", opts)
keymap("n", "<m-k>", "<C-w>k", opts)
keymap("n", "<m-l>", "<C-w>l", opts)
keymap("n", "<m-tab>", "<c-6>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move current line / block with Alt-j/k
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv-gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv-gv", opts)

-- Use s-h/l for beginning/end of line
keymap({ "n", "o", "x" }, "<s-h>", "^", opts)
keymap({ "n", "o", "x" }, "<s-l>", "g_", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

--
keymap("x", "p", [["_dP]])

-- Split navigation like I do in tmux
keymap("n", "<leader>-", "<C-w>s", opts)
keymap("n", "<leader>|", "<C-w>v", opts)

-- vim.keymap.set("n", "<leader>k", ":!python3 %<CR>", { noremap = false, silent = false })
-- :enew | .! <command>
--:vnew | read !python
keymap("n", "<leader>x", ":new tmp.md | read !q #<CR>", opts)

-- IDEAS:
-- Open a temporary question file.
-- If in the file, same command sends the file to `q` command
-- This sends the request to chatGPT

-- keymap("n", "n", "nzz", opts)
-- keymap("n", "N", "Nzz", opts)
-- keymap("n", "*", "*zz", opts)
-- keymap("n", "#", "#zz", opts)
-- keymap("n", "g*", "g*zz", opts)
-- keymap("n", "g#", "g#zz", opts)
--

--
-- vim.cmd [[:amenu 10.100 mousemenu.Goto\ Definition <cmd>lua vim.lsp.buf.definition()<CR>]]
-- vim.cmd [[:amenu 10.110 mousemenu.References <cmd>lua vim.lsp.buf.references()<CR>]]
-- -- vim.cmd [[:amenu 10.120 mousemenu.-sep- *]]
--
-- vim.keymap.set("n", "<RightMouse>", "<cmd>:popup mousemenu<CR>")
-- vim.keymap.set("n", "<Tab>", "<cmd>:popup mousemenu<CR>")
--
-- -- more good
--
-- -- tailwind bearable to work with
-- keymap({ "n", "x" }, "j", "gj", opts)
-- keymap({ "n", "x" }, "k", "gk", opts)
-- keymap("n", "<leader>w", ":lua vim.wo.wrap = not vim.wo.wrap<CR>", opts)
--
--
-- vim.api.nvim_set_keymap('t', '<C-;>', '<C-\\><C-n>', opts)
--
--
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
keymap({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
