return {
  'andymass/vim-matchup',
  event = 'BufReadPost',
  config = function()
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    vim.g.matchup_matchpref = {
      svelte = { tagnameonly = 1 },
      vue = { tagnameonly = 1 },
      typescriptreact = { tagnameonly = 1 },
      tsx = { tagnameonly = 1 },
      html = { tagnameonly = 1 },
      ['html-eex'] = { tagnameonly = 1 },
    }
  end,
  opts = {},
}
