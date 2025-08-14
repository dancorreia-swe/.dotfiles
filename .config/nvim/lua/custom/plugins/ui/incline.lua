return {
  'b0o/incline.nvim',
  dependencies = {
    { 'SmiteshP/nvim-navic', setup = {
      highlight = true,
    } },
    'nvim-tree/nvim-web-devicons',
  },
  -- Optional: Lazy load Incline
  event = 'VeryLazy',
  config = function()
    local helpers = require 'incline.helpers'
    local navic = require 'nvim-navic'
    local devicons = require 'nvim-web-devicons'

    require('incline').setup {
      hide = {
        cursorline = true,
      },
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
        placement = {
          vertical = 'bottom',
          horizontal = 'center',
        },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified
        local res = {
          ft_icon and { ' ', ft_icon, ' ', guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or '',
          ' ',
          { filename, gui = modified and 'bold,italic' or 'bold' },
          guibg = '',
        }
        if props.focused then
          for _, item in ipairs(navic.get_data(props.buf) or {}) do
            table.insert(res, {
              { ' > ', group = 'NavicSeparator' },
              { item.icon, group = 'NavicIcons' .. item.type },
              { item.name, group = 'NavicText' },
            })
          end
        end
        table.insert(res, ' ')

        local function get_harpoon_items()
          local harpoon = require 'harpoon'
          local marks = harpoon:list().items
          local current_file_path = vim.fn.expand '%:p:.'
          local label = {}

          for id, item in ipairs(marks) do
            if item.value == current_file_path then
              table.insert(label, { id .. ' ', guifg = '#FFFFFF', gui = 'bold' })
            else
              table.insert(label, { id .. ' ', guifg = '#434852' })
            end
          end

          if #label > 0 then
            -- table.insert(label, { '| ' })
            table.insert(label, 1, { '󰛢 ', guifg = '#61AfEf' })
          end
          return label
        end

        return { get_harpoon_items() }
      end,
    }
  end,
}
