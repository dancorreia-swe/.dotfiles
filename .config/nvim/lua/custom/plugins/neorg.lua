return {
  {
    'vhyrro/luarocks.nvim',
    priority = 1000,
    config = true,
  },
  {
    'nvim-neorg/neorg',
    dependencies = {
      'luarocks.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    build = ':Neorg sync-parsers',
    cmd = { 'Neorg' },
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = '*', -- Pin Neorg to the latest stable release
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},
          ['core.completion'] = {
            config = {
              engine = 'nvim-cmp',
            },
          },
          ['core.integrations.nvim-cmp'] = {},
          ['core.concealer'] = {},
          ['core.dirman'] = {
            config = {
              workspaces = {
                notes = '~/notes',
              },
              default_workspace = 'notes',
            },
          },
          ['core.highlights'] = {},
          ['core.summary'] = {},
          ['core.ui.calendar'] = {},
        },
      }

      vim.keymap.set('n', '<leader>[', '<cmd>Neorg index<CR>', { desc = 'Neorg Index' })
      vim.keymap.set('n', '<leader>]', '<cmd>Neorg return<CR>', { desc = 'Neorg Return' })

      vim.keymap.set('n', '<leader>jt', '<cmd>Neorg journal today<CR>', { desc = '[neorg] Journal today' })
      vim.keymap.set('n', '<leader>jT', '<cmd>Neorg journal tomorrow<CR>', { desc = '[neorg] Journal tomorrow' })
      vim.keymap.set('n', '<leader>jy', '<cmd>Neorg journal yesterday<CR>', { desc = '[neorg] Journal yesterday' })
      vim.keymap.set('n', '<leader>jp', '<cmd>Neorg journal template<CR>', { desc = '[neorg] Journal template' })
      vim.keymap.set('n', '<leader>jl', '<cmd>Neorg journal toc<CR>', { desc = '[neorg] Journal TOC' })

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },
}
