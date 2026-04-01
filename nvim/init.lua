vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
      vim.system({ "make" }, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/sainnhe/gruvbox-material",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/christoomey/vim-tmux-navigator",
  "https://github.com/b0o/SchemaStore.nvim",
  "https://github.com/zbirenbaum/copilot.lua",
})

-- ============================================================================
-- COLORSCHEME
-- ============================================================================

vim.cmd.colorscheme("gruvbox-material")

-- ============================================================================
-- PLUGIN SETUP
-- ============================================================================

require("nvim-autopairs").setup()

require("lualine").setup {
  options = {
    icons_enabled = false,
    theme = "gruvbox",
    component_separators = "|",
    section_separators = "",
  },
}

require("oil").setup {
  columns = { "icon" },
  view_options = { show_hidden = true },
  default_file_explorer = true,
}

require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
  },
}
pcall(require("telescope").load_extension, "fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help" })
vim.keymap.set("n", "<leader>?", builtin.oldfiles, { desc = "Find recently opened files" })
vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = "Fuzzily search in current buffer" })
vim.keymap.set("n", "<leader>st", builtin.live_grep, { desc = "Search text" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current word" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })

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

-- ============================================================================
-- LSP
-- ============================================================================

local servers = {
  bashls = {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
  },
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--completion-style=detailed", "--function-arg-placeholders", "--fallback-style=llvm" },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
  },
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
      gopls = {
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },
  html = {
    cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html", "templ" },
    init_options = {
      configurationSection = { "html", "css", "javascript" },
      embeddedLanguages = { css = true, javascript = true },
      provideFormatter = true,
    },
  },
  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  },
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  },
  ruff = {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  },
  terraformls = {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "terraform-vars" },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  },
  yamlls = {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    settings = {
      yaml = {
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
        format = { enable = true },
      },
    },
  },
}

vim.lsp.config("*", { root_markers = { ".git" } })
for name, config in pairs(servers) do
  vim.lsp.config(name, config)
end
vim.lsp.enable(vim.tbl_keys(servers))

vim.diagnostic.config { virtual_lines = true }

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_clients({ id = args.data.client_id })[1])

    vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.lsp.completion.enable(true, args.data.client_id, bufnr, { autotrigger = true })

    local map = vim.keymap.set
    local tb = require("telescope.builtin")
    map("n", "gd", tb.lsp_definitions, { buffer = 0 })
    map("n", "gr", tb.lsp_references, { buffer = 0 })
    map("n", "gl", vim.diagnostic.open_float, { buffer = 0 })
    map("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
    map("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
    map("n", "K", vim.lsp.buf.hover, { buffer = 0 })
    map("n", "<leader>lf", vim.lsp.buf.format, { buffer = 0 })
    map("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
    map("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })

    if vim.bo[bufnr].filetype == "lua" then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", {}),
  callback = function()
    vim.hl.on_yank { higroup = "IncSearch", timeout = 40 }
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RememberCursor", {}),
  callback = function()
    local last_pos = vim.fn.line "'\""
    if last_pos > 1 and last_pos <= vim.fn.line "$" then
      vim.cmd 'normal! g`"'
      vim.cmd "normal zz"
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("TrimWhitespace", {}),
  command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.nrql",
  command = "set filetype=sql",
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================

local terminal_state = { buf = nil, win = nil, is_open = false }

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

vim.keymap.set("n", "<leader>t", FloatingTerminal, { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc><Esc>", function()
  if terminal_state.is_open then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end, { desc = "Close terminal" })
