return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },
  keys = {
    {
      '<leader>m',
      function()
        require('harpoon'):list():add()
      end,
      desc = '[M]ark file',
    },
    {
      '<leader>M',
      function()
        require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())
      end,
      desc = '[S]earch [M]arked Files',
    },
    {
      '<leader>j',
      function()
        require('harpoon'):list():select(1)
      end,
      desc = '[j] Harpoon Buffer [1]',
    },
    {
      '<leader>k',
      function()
        require('harpoon'):list():select(2)
      end,
      desc = '[k] Harpoon Buffer [2]',
    },
    {
      '<leader>n',
      function()
        require('harpoon'):list():select(3)
      end,
      desc = '[n] Harpoon Buffer [3]',
    },
    {
      '<leader>p',
      function()
        require('harpoon'):list():select(4)
      end,
      desc = '[m] Harpoon Buffer [4]',
    },
    {
      '<C-p>',
      function()
        require('harpoon'):list():prev()
      end,
      desc = 'Select [P]revious Harpoon Buffer',
    },
    {
      '<C-n>',
      function()
        require('harpoon'):list():next()
      end,
      desc = 'Select [N]ext Harpoon Buffer',
    },
    {
      '<C-v>',
      function()
        require('harpoon').ui:select_menu_item { vsplit = true }
      end,
      buffer = true,
    },
    {
      '<C-x>',
      function()
        require('harpoon').ui:select_menu_item { split = true }
      end,
      buffer = true,
    },
  },
}
