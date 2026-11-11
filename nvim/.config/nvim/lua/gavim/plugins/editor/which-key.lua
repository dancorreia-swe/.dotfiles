return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts_extend = { 'spec' },
  opts = {
    preset = 'helix',
    defaults = {},
    spec = {
      {
        mode = { 'n', 'x' },
        { '<leader><tab>', group = 'tabs' },
        { '<leader>a', group = 'ai' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug/profile' },
        { '<leader>dp', group = 'profiler' },
        { '<leader>h', group = 'haunt (annotations)' },
        { '<leader>o', group = 'obsidian' },
        { '<leader>od', group = 'daily notes' },
        { '<leader>sn', group = 'noice' },
        { '<leader>f', group = 'file/find' },
        { '<leader>g', group = 'git' },
        { '<leader>gh', group = 'hunks' },
        { '<leader>j', group = 'jj' },
        { '<leader>jb', group = 'bookmark' },
        { '<leader>jp', group = 'picker' },
        { '<leader>jg', group = 'git/remote' },
        { '<leader>jT', group = 'tag' },
        { '<leader>q', group = 'quit/session' },
        { '<leader>s', group = 'search' },
        { '<leader>u', group = 'ui' },
        { '<leader>x', group = 'diagnostics/quickfix' },
        { '[', group = 'prev' },
        { ']', group = 'next' },
        { 'g', group = 'goto' },
        { 'gr', group = 'lsp' },
        { 'z', group = 'fold' },
        {
          '<leader>b',
          group = 'buffer',
          expand = function()
            return require('which-key.extras').expand.buf()
          end,
        },
        {
          '<leader>w',
          group = 'windows',
          proxy = '<c-w>',
          expand = function()
            return require('which-key.extras').expand.win()
          end,
        },
        -- better descriptions
        { 'gx', desc = 'Open with system app' },
        -- relabel Nvim 0.12+ LSP defaults (`:h lsp-defaults`) without rebinding them;
        -- gri/grr/grt are overridden by snacks.lua with their own descs
        { 'gra', desc = 'Code Action', mode = { 'n', 'x' } },
        { 'grn', desc = 'Rename' },
        { 'grx', desc = 'Run Codelens' },
      },
    },
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Keymaps (which-key)',
    },
    {
      '<c-w><space>',
      function()
        require('which-key').show { keys = '<c-w>', loop = true }
      end,
      desc = 'Window Hydra Mode (which-key)',
    },
  },
  config = function(_, opts)
    local wk = require 'which-key'
    wk.setup(opts)
    if not vim.tbl_isempty(opts.defaults) then
      vim.notify('which-key: opts.defaults is deprecated. Please use opts.spec instead.', vim.log.levels.WARN, opts)
      wk.add(opts.defaults)
    end
  end,
}
