return {
  'MagicDuck/grug-far.nvim',
  lazy = true,
  cmd = { 'GrugFar' },
  keys = {
    { '<leader>lee', '<cmd>GrugFar<cr>', desc = 'GrugFar' },
    {
      '<leader>lef',
      function()
        require('grug-far').open { prefills = { paths = vim.fn.expand '%' } }
      end,
      desc = 'GrugFar Current File',
    },
    {
      '<leader>lev',
      mode = 'v',
      function()
        require('grug-far').with_visual_selection { prefills = { paths = vim.fn.expand '%' } }
      end,
      desc = 'GrugFar Visual Selection',
    },
    {
      '<leader>lew',
      function()
        require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } }
      end,
      desc = 'GrugFar Current Word',
    },
  },
  config = function()
    require('grug-far').setup {
      -- options, see Configuration section below
      -- there are no required options atm
      -- engine = 'ripgrep' is default, but 'astgrep' can be specified
    }
  end,
}
