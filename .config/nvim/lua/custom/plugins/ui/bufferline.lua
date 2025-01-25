return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    vim.opt.termguicolors = true
    require('bufferline').setup {
      options = {
        hover = {
          enabled = true,
          delay = 200,
          reveal = { 'close' },
        },
      },
    }

    vim.keymap.set('n', '<leader>t', '<Cmd>BufferLinePick<CR>', { desc = 'Pick Buffer [T]ab', silent = true })
    vim.keymap.set('n', '<C-;>', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Cycle Buffer Tab Next' })
    vim.keymap.set('n', '<C-l>', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Cycle Buffer Tab Prev' })
  end,
}
