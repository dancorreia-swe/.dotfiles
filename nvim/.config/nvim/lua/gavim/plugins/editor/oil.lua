return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ['_'] = { 'actions.parent', mode = 'n' },
      ['-'] = { 'actions.open_cwd', mode = 'n' },
      ['q'] = { 'actions.close', mode = 'n' },
    },
  },
  keys = {
    { '<leader>_', '<CMD>Oil<CR>', desc = 'Open parent directory on window' },
  },
  -- Optional dependencies
  dependencies = { 'nvim-mini/mini.icons', opts = {} },
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function(_, opts)
    require('oil').setup(opts)

    -- Sync file renames with Snacks for LSP updates
    vim.api.nvim_create_autocmd('User', {
      pattern = 'OilActionsPost',
      callback = function(event)
        if event.data.actions[1].type == 'move' then
          Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
        end
      end,
    })
  end,
}
