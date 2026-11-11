_G.GaVim = require 'gavim.util'

require 'gavim.config.options'
require 'gavim.config.autocmds'
require 'gavim.config.keymaps'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

GaVim.plugin.setup()

require('lazy').setup({
  { import = 'gavim.plugins.ai' },
  { import = 'gavim.plugins.editor' },
  { import = 'gavim.plugins.lsp' },
  { import = 'gavim.plugins.coding' },
  { import = 'gavim.plugins.lang' },
  { import = 'gavim.plugins.ui' },
}, {
  dev = {
    path = '~/Code/oss/',
  },
  defaults = { lazy = true },
  checker = { enabled = true, notify = false },
  -- no plugin here needs luarocks; skip the hererocks setup and its health errors
  rocks = { enabled = false },
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
