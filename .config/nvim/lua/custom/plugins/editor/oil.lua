return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ['_'] = { 'actions.parent', mode = 'n' },
      ['-'] = { 'actions.open_cwd', mode = 'n' },
      ['q'] = { 'actions.close', mode = 'n' },
    },
  },
  keys = {
    { '<leader>_', '<CMD>Oil --float<CR>', desc = 'Open parent directory on window' },
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
