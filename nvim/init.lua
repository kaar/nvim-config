vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- TODO:
-- UndoTree is now an option... "mbbill/undotree",
-- diff view built in to nvim 0.12

-- https://neovim.io/doc/user/pack/#vim.pack.add()
vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/sainnhe/gruvbox-material",
  "https://github.com/zbirenbaum/copilot.lua",

  "https://github.com/tpope/vim-fugitive",

  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  "https://github.com/nvim-lua/plenary.nvim",

  "https://github.com/neovim/nvim-lspconfig",

  "https://github.com/j-hui/fidget.nvim",

  "https://github.com/b0o/SchemaStore.nvim",

  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",

  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/mason-org/mason-lspconfig.nvim",
  "https://github.com/stevearc/oil.nvim",
})

vim.cmd.colorscheme("gruvbox-material")


-- https://neovim.io/doc/user/diagnostic/
-- Nvim provides these handlers by default: "virtual_text", "virtual_lines", "signs", and "underline".
vim.diagnostic.config { virtual_lines = true }

vim.lsp.enable('ruff')
vim.lsp.enable('pyright')
vim.lsp.enable('terraformls')
vim.lsp.enable('bashls')
vim.lsp.enable('clangd')
vim.lsp.enable('gopls')
vim.lsp.enable('lua_ls')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('cssls')
vim.lsp.enable('html')
vim.lsp.enable('ts_ls')
vim.lsp.enable('jsonls')
vim.lsp.enable('yamlls')

vim.lsp.config.yamlls.settings = {
  yaml = {
    schemaStore = {
      -- You must disable built-in schemaStore support if you want to use
      -- this plugin and its advanced options like `ignore`.
      enable = false,
      -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
      url = "",
    },
    schemas = require('schemastore').yaml.schemas(),
  },
}
vim.lsp.config.lua_ls.settings = {
  Lua = {
    runtime = { version = "LuaJIT"
    },
    diagnostics = { globals = { "vim" } },
    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    telemetry = { enable = false },
  },
}

require("mason").setup()
require("mason-lspconfig").setup()
require("oil").setup {
  columns = { "icon" },
  view_options = { show_hidden = true },
  default_file_explorer = true,
}
require("nvim-autopairs").setup()
require("lualine").setup {
  options = {
    icons_enabled = false,
    theme = "gruvbox",
    component_separators = "|",
    section_separators = "",
  },
}
require("fidget").setup({})


local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set("n", "<leader>m", function() harpoon:list():add() end, { desc = "Mark file with Harpoon" })
vim.keymap.set("n", "<leader>l", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "List Harpoon files" })
for _, idx in ipairs { 1, 2, 3, 4, 5 } do
  vim.keymap.set("n", string.format("<space>%d", idx), function() harpoon:list():select(idx) end)
end

require("copilot").setup {
  panel = { enabled = true, auto_refresh = true },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-e>",
      accept_word = false,
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = true,
    markdown = true,
    help = true,
    gitcommit = true,
    gitrebase = true,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
}


local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local yank_group = augroup("HighlightYank", {})
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank {
      higroup = "IncSearch",
      timeout = 40,
    }
  end,
})

-- Remember cursor position
local cursor_group = augroup("RememberCursor", {})
autocmd("BufReadPost", {
  group = cursor_group,
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line "'\""
    if last_pos > 1 and last_pos <= vim.fn.line "$" then
      vim.cmd 'normal! g`"'
      vim.cmd "normal zz"
    end
  end,
})

-- Trim trailing whitespace on save
local trim_group = augroup("TrimWhitespace", {})
autocmd({ "BufWritePre" }, {
  group = trim_group,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Set filetype for NRQL files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.nrql",
  command = "set filetype=sql",
})

-- ============================================================================
-- FLOATING TERMINAL
-- https://github.com/radleylewis/nvim-lite/blob/youtube_demo/init.lua
-- ============================================================================

local terminal_state = {
  buf = nil,
  win = nil,
  is_open = false,
}

local function FloatingTerminal()
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    return
  end

  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal_state.buf].bufhidden = "hide"
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
  vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })
  vim.api.nvim_set_option_value("winblend", 0, { win = terminal_state.win })
  vim.api.nvim_set_option_value("winhighlight", "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder", { win = terminal_state.win })

  if vim.api.nvim_buf_line_count(terminal_state.buf) <= 1 and vim.api.nvim_buf_get_lines(terminal_state.buf, 0, 1, false)[1] == "" then
    vim.fn.jobstart(os.getenv("SHELL"), { term = true })
  end

  terminal_state.is_open = true
  vim.cmd "startinsert"

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = terminal_state.buf,
    once = true,
    callback = function()
      if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
        vim.api.nvim_win_close(terminal_state.win, false)
        terminal_state.is_open = false
      end
    end,
  })
end
local function CloseFloatingTerminal()
  if terminal_state.is_open then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end

-- Key mappings
vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc><Esc>", CloseFloatingTerminal, { noremap = true, silent = true, desc = "Close terminal" })
