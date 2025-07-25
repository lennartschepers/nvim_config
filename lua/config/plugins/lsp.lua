return {
  {

    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require("lspconfig")
      -- require("lspconfig").lua_ls.setup { capabilities = capabilities }
      -- Lua
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
      }

      -- Python
      lspconfig.pyright.setup {
        capabilities = capabilities,
        filetypes = { "python" },
      }
      -- Go
      lspconfig.gopls.setup {
        capabilities = capabilities,
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          if not client:supports_method('textDocument/willSaveWaitUntil')
              and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
              end,
            })
          end
        end,
      })
    end,
    ft = { "lua", "python", "go" }, -- Only load lsp plugin for these filetypes
  }
}
