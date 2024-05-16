return {
  {
    'vhyrro/luarocks.nvim',
    priority = 1000,
    config = true,
  },
  {
    'nvim-neorg/neorg',
    dependencies = { 'luarocks.nvim' },
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = '*', -- Pin Neorg to the latest stable release
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},
          ['core.concealer'] = {},
          ['core.dirman'] = {
            config = {
              workspaces = {
                notes = '~/notes',
              },
              default_workspace = 'notes',
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>[', '<cmd>Neorg index<CR>', { desc = 'Neorg Index' })
      vim.keymap.set('n', '<leader>]', '<cmd>Neorg return<CR>', { desc = 'Neorg Return' })

      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2
    end,
  },
}
