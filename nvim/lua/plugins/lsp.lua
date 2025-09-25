-- Using native vim.lsp.config (Neovim 0.11+)
return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "folke/neodev.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Still needed for neodev.nvim compatibility
      "neovim/nvim-lspconfig",

      -- Progress notifications
      { "j-hui/fidget.nvim", opts = {} },

      -- Schema information
      "b0o/SchemaStore.nvim",
    },
    config = function()
      require("neodev").setup {
        -- library = {
        --   plugins = { "nvim-dap-ui" },
        --   types = true,
        -- },
      }

      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      -- Global configuration for all LSP clients
      vim.lsp.config('*', {
        capabilities = capabilities,
        root_markers = { '.git' },
      })

      -- Configure individual LSP servers using vim.lsp.config
      vim.lsp.config('ruff', {
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
        init_options = {
          settings = {
            args = {},
          },
        },
      })

      vim.lsp.config('terraformls', {
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'terraform', 'terraform-vars' },
        root_markers = { '.terraform', '*.tf', '.git' },
      })

      vim.lsp.config('pyright', {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
        settings = {
          -- pyright = {
          --   disableOrganizeImports = true,
          -- },
          -- python = {
          --   analysis = {
          --     ignore = { "*" },
          --   },
          -- },
        },
      })

      vim.lsp.config('bashls', {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'sh', 'bash' },
        root_markers = { '.git' },
      })

      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      vim.lsp.config('gopls', {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
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
      })

      vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            workspace = {
              checkThirdParty = false,
            },
          },
        },
      })

      vim.lsp.config('rust_analyzer', {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
      })

      vim.lsp.config('cssls', {
        cmd = { 'vscode-css-language-server', '--stdio' },
        filetypes = { 'css', 'scss', 'less' },
        root_markers = { 'package.json', '.git' },
      })

      vim.lsp.config('html', {
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html', 'templ' },
        root_markers = { 'package.json', '.git' },
        init_options = {
          configurationSection = { 'html', 'css', 'javascript' },
          embeddedLanguages = {
            css = true,
            javascript = true,
          },
          provideFormatter = true,
        },
      })

      vim.lsp.config('ts_ls', {
        cmd = { 'typescript-language-server', '--stdio' },
        filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
        root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
      })

      vim.lsp.config('jsonls', {
        cmd = { 'vscode-json-language-server', '--stdio' },
        filetypes = { 'json', 'jsonc' },
        root_markers = { 'package.json', '.git' },
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config('yamlls', {
        cmd = { 'yaml-language-server', '--stdio' },
        filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
        root_markers = { '.git' },
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
            format = {
              enable = true,
            },
          },
        },
      })

      -- Mason setup for tool installation
      require("mason").setup()
      local ensure_installed = {
        "stylua",
        "lua-language-server",
        "ruff",
        "clangd",
        "prettier",
        "bash-language-server",
        "terraform-ls",
        "pyright",
        "gopls",
        "rust-analyzer",
        "typescript-language-server",
        "yaml-language-server",
      }

      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      -- Enable all configured LSP servers
      vim.lsp.enable({
        'ruff',
        'terraformls',
        'pyright',
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

      local disable_semantic_tokens = {
        lua = true,
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

          local builtin = require "telescope.builtin"
          local map = vim.keymap.set

          vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
          map("n", "gd", builtin.lsp_definitions, { buffer = 0 })
          map("n", "gl", vim.diagnostic.open_float, { buffer = 0 })
          map("n", "gr", builtin.lsp_references, { buffer = 0 })
          map("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
          map("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
          map("n", "K", vim.lsp.buf.hover, { buffer = 0 })
          map("n", "<leader>lf", vim.lsp.buf.format, { buffer = 0 })
          map("n", "<space>cr", vim.lsp.buf.rename, { buffer = 0 })
          map("n", "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })

          local filetype = vim.bo[bufnr].filetype
          if disable_semantic_tokens[filetype] then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
    end,
  },
}
