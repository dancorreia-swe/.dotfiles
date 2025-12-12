return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local lspconfig = require 'lspconfig'
      local configs = require 'lspconfig.configs'

      -- Shim expert if missing
      if not configs.expert then
        configs.expert = {
          default_config = {
            cmd = { 'expert' },
            filetypes = { 'elixir', 'eelixir', 'heex' },
            root_dir = lspconfig.util.root_pattern('mix.exs', '.git'),
            single_file_support = true,
          },
          docs = {
            description = [[
https://github.com/elixir-expert/expert

Expert is the official language server implementation for the Elixir programming language.
]],
          },
        }
      end

      -- Enable it through LazyVim's opts.servers
      opts.servers = opts.servers or {}
      opts.servers.expert = {}
    end,
  },

  {
    'mason-org/mason.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        'expert',
      })
    end,
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
