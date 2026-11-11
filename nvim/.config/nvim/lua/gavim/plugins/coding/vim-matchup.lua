return {
  'andymass/vim-matchup',
  -- matchup replaces the builtin matchit/matchparen (disabled in init.lua)
  -- and should not be lazy-loaded
  lazy = false,
  ---@type matchup.Config
  opts = {
    treesitter = {
      stopline = 500,
    },
  },
}
