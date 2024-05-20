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
          ['core.keybinds'] = {
            config = {
              neorg_leader = ',',
              hook = function(keybinds)
                keybinds.remap_event('norg', 'i', '<S-CR>', 'core.itero.next-iteration')
                keybinds.map('norg', 'n', keybinds.leader .. 'jt', '<cmd>Neorg journal today<CR>', { desc = '[neorg] journal today' })
                keybinds.map('norg', 'n', keybinds.leader .. 'jp', '<cmd>Neorg journal template<CR>', { desc = '[neorg] journal template' })
                keybinds.map('norg', 'n', keybinds.leader .. 'jT', '<cmd>Neorg journal tomorrow<CR>', { desc = '[neorg] journal tomorrow' })
                keybinds.map('norg', 'n', keybinds.leader .. 'jy', '<cmd>Neorg journal yesterday<CR>', { desc = '[neorg] journal yesterday' })
                keybinds.map_event_to_mode('norg', {
                  n = {
                    { keybinds.leader .. 'ge', 'core.esupports.hop.hop-link', 'external', opts = { desc = 'Open External Link' } },
                  },
                }, {})
              end,
            },
          },
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

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },
}
