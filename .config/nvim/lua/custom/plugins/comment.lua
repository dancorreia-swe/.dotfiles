-- "gc" to comment visual regions/lines
return {
  'numToStr/Comment.nvim',
  config = function()
    require('Comment').setup {
      pre_hook = function()
        return vim.bo.commentstring
      end,
    }
  end,
  lazy = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'JoosepAlviste/nvim-ts-context-commentstring',
    {
      'folke/ts-comments.nvim',
      opts = {},
      event = 'VeryLazy',
      enabled = vim.fn.has 'nvim-0.10.0' == 1,
    },
  },
}
