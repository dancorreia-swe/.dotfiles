return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        elixirls = {
          keys = {
            {
              '<leader>cp',
              function()
                local params = vim.lsp.util.make_position_params()
                vim.lsp.execute {
                  command = 'manipulatePipes:serverid',
                  arguments = { 'toPipe', params.textDocument.uri, params.position.line, params.position.character },
                }
              end,
              desc = 'To Pipe',
            },
            {
              '<leader>cP',
              function()
                local params = vim.lsp.util.make_position_params()
                vim.lsp.execute {
                  command = 'manipulatePipes:serverid',
                  arguments = { 'fromPipe', params.textDocument.uri, params.position.line, params.position.character },
                }
              end,
              desc = 'From Pipe',
            },
          },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'elixir', 'heex', 'eex' })
      vim.treesitter.language.register('markdown', 'livebook')
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'jfpedroza/neotest-elixir',
    },
    opts = {
      adapters = {
        ['neotest-elixir'] = {},
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = {
        elixir = { 'credo' },
      }

      opts.linters = {
        credo = {
          condition = function(ctx)
            return vim.fs.find({ '.credo.exs' }, { path = ctx.filename, upward = true })[1]
          end,
        },
      }
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    optional = true,
    ft = function(_, ft)
      vim.list_extend(ft, { 'livebook' })
    end,
  },
}
