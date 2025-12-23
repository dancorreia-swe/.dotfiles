return {
  'mrdwarf7/lazyjui.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    -- stylua: ignore
    {
      '<Leader>jj', function() require('lazyjui').open() end,
    },
  },
}
