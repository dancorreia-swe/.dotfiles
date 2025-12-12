require 'config.options'
require 'config.autocmds'
require 'config.keybinds'

_G.GaVim = require 'util'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

GaVim.plugin.setup()

require('lazy').setup({
  { import = 'plugins.ai' },
  { import = 'plugins.editor' },
  { import = 'plugins.lsp' },
  { import = 'plugins.coding' },
  { import = 'plugins.dap' },
  { import = 'plugins.lang' },
  { import = 'plugins.ui' },
  { import = 'plugins.test' },
}, {
  defaults = { lazy = true },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
