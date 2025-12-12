return {
  'Bekaboo/dropbar.nvim',
  event = 'LazyFile',
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
  },
  keys = {
    {
      '<leader>;',
      function()
        require('dropbar.api').pick()
      end,
      mode = 'n',
      desc = 'Pick symbols in winbar',
    },
    {
      '[;',
      function()
        require('dropbar.api').goto_context_start()
      end,
      mode = 'n',
      desc = 'Go to start of current context',
    },
    {
      '];',
      function()
        require('dropbar.api').goto_context_end()
      end,
      mode = 'n',
      desc = 'Go to end of current context',
    },
  },
}
