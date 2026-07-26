vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- TODO:
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

vim.lsp.enable({
  'ruff',
  'pyright',
  'terraformls',
  'bashls',
  'clangd',
  'gopls',
  'lua_ls',
  'rust_analyzer',
  'cssls',
  'html',
  'ts_ls',
  'jsonls',
  'yamlls',
})

vim.lsp.config('yamlls', {
  settings = {
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
  },
})
vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
})
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
  before_init = function(_, config)
    local root = config.root_dir
    local venv = root and (root .. "/.venv/bin/python")
    if venv and vim.uv.fs_stat(venv) then
      config.settings.python.pythonPath = venv
    end
  end,
})
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

require("mason").setup()
require("mason-lspconfig").setup({ automatic_enable = false })
require("oil").setup {
  columns = { "icon" },
  view_options = { show_hidden = true },
  default_file_explorer = true,
}
require("nvim-autopairs").setup()
require("lualine").setup {
  options = {
    icons_enabled = false,
    theme = "auto", -- picks the matching theme for the active colorscheme
    component_separators = "|",
    section_separators = "",
  },
}
require("fidget").setup({})

-- LSP keymaps (supplements Neovim 0.12 defaults: grn, gra, grr, K), See: help lsp-defaults
-- Note: `gd` here shadows the built-in `gd` (jump to local declaration in normal
-- mode). Intentional: we prefer the Telescope picker for definitions. Use `gD`
-- for the legacy jump-to-declaration behaviour.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = vim.keymap.set
    local builtin = require("telescope.builtin")
    map("n", "gd", builtin.lsp_definitions, { buffer = args.buf })
    map("n", "gr", builtin.lsp_references, { buffer = args.buf })
    map("n", "gl", vim.diagnostic.open_float, { buffer = args.buf })
    map("n", "<leader>lf", vim.lsp.buf.format, { buffer = args.buf })
  end,
})


local harpoon = require("harpoon")
harpoon:setup()
vim.keymap.set("n", "<leader>m", function() harpoon:list():add() end, { desc = "Mark file with Harpoon" })
vim.keymap.set("n", "<leader>l", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
  { desc = "List Harpoon files" })
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
    vim.hl.on_yank {
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

