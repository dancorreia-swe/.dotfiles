return {
  'rose-pine/neovim',
  lazy = false,
  priority = 1000,
  name = 'rose-pine',
  config = function()
    require('rose-pine').setup {
      dim_inactive_windows = true,
      styles = {
        transparency = true,
      },
    }
    vim.cmd 'colorscheme rose-pine'
  end,
}
