-- Consolidated small plugin specs
return {
  -- Auto-close inactive buffers
  {
    'chrisgrieser/nvim-early-retirement',
    config = true,
    event = 'VeryLazy',
  },

  -- Session management
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
  },

  -- Color highlighter
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {},
  },

  -- Auto-detect indentation
  {
    'nmac427/guess-indent.nvim',
    event = 'LazyFile',
    cmd = 'GuessIndent',
    opts = {},
  },
}
