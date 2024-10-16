return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    ---@diagnostic disable-next-line: missing-parameter
    harpoon:setup()

    vim.keymap.set('n', '<leader>m', function()
      harpoon:list():add()
    end, { desc = '[M]ark file' })

    vim.keymap.set('n', '<leader>sm', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = '[S]earch [M]arked Files' })

    vim.keymap.set('n', '<leader>j', function()
      harpoon:list():select(1)
    end, { desc = '[j] Harpoon Buffer [1]' })

    vim.keymap.set('n', '<leader>k', function()
      harpoon:list():select(2)
    end, { desc = '[k] Harpoon Buffer [2]' })

    vim.keymap.set('n', '<leader>p', function()
      harpoon:list():select(3)
    end, { desc = '[o] Harpoon Buffer [3]' })

    vim.keymap.set('n', '<leader>n', function()
      harpoon:list():select(4)
    end, { desc = '[m] Harpoon Buffer [4]' })

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<C-p>', function()
      harpoon:list():prev()
    end, { desc = 'Select [P]revious Harpoon Buffer' })

    vim.keymap.set('n', '<C-n>', function()
      harpoon:list():next()
    end, { desc = 'Select [N]ext Harpoon Buffer' })

    harpoon:extend {
      UI_CREATE = function(cx)
        vim.keymap.set('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-x>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr })
      end,
    }
  end,
}
