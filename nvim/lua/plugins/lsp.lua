-- Using native vim.lsp.config (Neovim 0.11+)
return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "folke/neodev.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Collection of LSP server configurations
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
      -- :help lspconfig-all
      "neovim/nvim-lspconfig",

      -- Progress notifications
      { "j-hui/fidget.nvim", opts = {} },

      -- Schema information
      "b0o/SchemaStore.nvim",
    },
    config = function()
      local servers = {
        ruff = {
          cmd = { 'ruff', 'server' },
          filetypes = { 'python' },
          root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
          init_options = {
            settings = {
              args = {},
            },
          },
        },

        terraformls = {
          cmd = { 'terraform-ls', 'serve' },
          filetypes = { 'terraform', 'terraform-vars' },
          root_markers = { '.terraform', '*.tf', '.git' },
        },

        pyright = {
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
          root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
          settings = {},
        },

        bashls = {
          cmd = { 'bash-language-server', 'start' },
          filetypes = { 'sh', 'bash' },
          root_markers = { '.git' },
        },

        clangd = {
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
        },

        gopls = {
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
        },

        -- lua_ls quit with exit code 127 and signal 0.
        -- [ERROR][2025-12-02 20:09:24] ...p/_transport.lua:36	"rpc"	"lua-language-server"	"stderr"
        -- "/home/kaar/.local/share/nvim/mason/packages/lua-language-server/libexec/bin/lua-language-server:
        -- error while loading shared libraries: libbfd-2.38-system.so: cannot open shared object file: No such file or directory\n"
        --
        -- https://github.com/LuaLS/lua-language-server/issues/3301
        --
        -- I can find /lib/libbfd-2.45.1.so
        -- Not sure why it's looking for 2.38 specifically and why it does not exists on the system.
        -- Others have the same issue. See Github issue above.
        --
        -- https://github.com/mason-org/mason-registry/pull/12567#pullrequestreview-3529895120
        -- Temporary workaround is to install 3.15.0 version of lua-language-server
        -- :MasonInstall lua-language-server@3.15.0
        lua_ls = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
              },
              -- Do not send telemetry
              telemetry = {
                enable = false,
              },
            },
          },
        },

        rust_analyzer = {
          cmd = { 'rust-analyzer' },
          filetypes = { 'rust' },
          root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
        },

        cssls = {
          cmd = { 'vscode-css-language-server', '--stdio' },
          filetypes = { 'css', 'scss', 'less' },
          root_markers = { 'package.json', '.git' },
        },

        html = {
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
        },

        ts_ls = {
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
          root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
        },

        jsonls = {
          cmd = { 'vscode-json-language-server', '--stdio' },
          filetypes = { 'json', 'jsonc' },
          root_markers = { 'package.json', '.git' },
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          },
        },

        yamlls = {
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
        },
      }

      -- Configure and enable each server
      for name, config in pairs(servers) do
        -- Set '.git' as default root marker if not specified
        if not config.root_markers then
          config.root_markers = { '.git' }
        end
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

      local capabilities = nil
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end
      -- Global configuration for all LSP clients
      vim.lsp.config('*', {
        capabilities = capabilities,
        root_markers = { '.git' },
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
        "shfmt",
        "terraform-ls",
        "pyright",
        "gopls",
        "rust-analyzer",
        "typescript-language-server",
        "yaml-language-server",
      }

      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

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
