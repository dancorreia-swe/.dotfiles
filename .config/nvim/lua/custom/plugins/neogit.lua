return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed, not both.
    'nvim-telescope/telescope.nvim', -- optional
    'ibhagwan/fzf-lua', -- optional
  },
  opts = {
    telescope_sorter = function()
      return require('telescope').extensions.fzf.native_fzf_sorter()
    end,
  },
  config = function()
    require('neogit').setup {
      integrations = {
        diffview = true,
      },
    }

    vim.keymap.set('n', '<leader>hG', function()
      require('neogit').open()
    end, { desc = '[G]it Gui' })
  end,
}
