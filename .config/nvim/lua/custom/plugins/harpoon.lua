return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    ---@diagnostic disable-next-line: missing-parameter
    harpoon:setup()

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Mark [A] file' })

    vim.keymap.set('n', '<leader>n', function()
      harpoon:list():select(1)
    end, { desc = 'Go to (1) Harpoon buffer' })

    vim.keymap.set('n', '<leader>p', function()
      harpoon:list():select(2)
    end, { desc = 'Go to (2) Harpoon buffer' })

    --[[ vim.keymap.set('n', '<C-n>', function()
      harpoon:list():select(3)
    end)

    vim.keymap.set('n', '<C-s>', function()
      harpoon:list():select(4)
    end) ]]

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>j', function()
      harpoon:list():prev()
    end, { desc = 'Toggle next Harpoon buffer' })

    vim.keymap.set('n', '<leader>k', function()
      harpoon:list():next()
    end, { desc = 'Toggle previous Harpoon buffer' })

    -- basic telescope configuration
    local conf = require('telescope.config').values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      local make_finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require('telescope.finders').new_table {
          results = paths,
        }
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
          attach_mappings = function(prompt_buffer_number, map)
            map(
              'n',
              'dd', -- your mapping here
              function()
                local state = require 'telescope.actions.state'
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_buffer_number)

                harpoon:list():remove_at(selected_entry.index)
                current_picker:refresh(make_finder())
              end,
              { desc = 'Delete entry' }
            )
            map(
              'n',
              '<C-d>', -- your mapping here
              function()
                local state = require 'telescope.actions.state'
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_buffer_number)

                harpoon:list():remove_at(selected_entry.index)
                current_picker:refresh(make_finder())
              end
            )

            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>se', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon window' })
  end,
}
