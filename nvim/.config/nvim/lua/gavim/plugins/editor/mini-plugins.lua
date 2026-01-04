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
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
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
