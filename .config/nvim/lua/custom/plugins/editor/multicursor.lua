return {
  {
    'jake-stewart/multicursor.nvim',
    event = 'VeryLazy',
    config = function()
      local mc = require 'multicursor-nvim'
      mc.setup()
      vim.keymap.set({ 'n', 'v' }, '<M-e>', function()
        mc.matchAddCursor(1)
      end)

      vim.keymap.set({ 'n', 'v' }, '<M-f>', function()
        mc.matchSkipCursor(1)
      end)

      vim.keymap.set('n', '<esc>', function()
        if mc.cursorsEnabled() then
          mc.clearCursors()
        end
      end)
    end,
  },
}
