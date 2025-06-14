return {

  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
    {
      'folke/lazydev.nvim',
      opts = {
        library = {
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      },
    },
  },

  opts = function()
    ---@class PluginLspOpts
    local ret = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = 'if_many',
          prefix = '●',
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
          -- prefix = "icons",
        },
        severity_sort = true,
        -- signs = {
        --   text = {
        --     [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
        --     [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
        --     [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
        --     [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
        --   },
        -- },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
        exclude = { 'vue' },         -- filetypes for which you don't want to enable inlay hints
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP Server Settings
      servers = {
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          -- ---@type LazyKeysSpec[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = 'Replace',
              },
              doc = {
                privateName = { '^_' },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = 'Disable',
                semicolon = 'Disable',
                arrayIndex = 'Disable',
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    }
    return ret
  end,
  config = function(_, opts)
    local blink_compat = require('blink.cmp').get_lsp_capabilities()
    local lspconfig = require 'lspconfig'
    for server, config in pairs(opts.servers) do
      config.capabilities = blink_compat
      lspconfig[server].setup(config)
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local c = vim.lsp.get_client_by_id(args.data.client_id)
        if not c then
          return
        end

        if vim.bo.filetype == 'lua' then
          -- Format the current buffer on save
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format { bufnr = args.buf, id = c.id }
            end,
          })
        end
      end,
    })
  end,
}
