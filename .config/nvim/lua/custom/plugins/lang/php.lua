return {
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function()
      local dap = require 'dap'
      dap.adapters.php = {
        type = 'executable',
        command = 'php-debug-adapter',
        args = {},
      }
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'V13Axel/neotest-pest',
      'olimorris/neotest-phpunit',
    },
    opts = {
      adapters = {
        'neotest-pest',
        ['neotest-phpunit'] = {
          root_ignore_files = { 'tests/Pest.php' },
        },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'php' } },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        intelephense = {
          enabled = true,
        },
      },
    },
  },
}
