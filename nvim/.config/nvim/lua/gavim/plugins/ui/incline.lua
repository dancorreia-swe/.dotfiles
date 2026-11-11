-- Floating filename + harpoon marks per window.
-- (breadcrumbs live in the dropbar winbar, so no navic here)
return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-mini/mini.icons' },
  opts = function()
    local helpers = require 'incline.helpers'

    local function harpoon_marks(buf)
      if not package.loaded['harpoon'] then
        return {}
      end
      local ok, list = pcall(function()
        return require('harpoon'):list().items
      end)
      if not ok then
        return {}
      end
      local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':.')
      local label = {}
      for id, item in ipairs(list) do
        if item.value == current then
          table.insert(label, { id .. ' ', group = 'Title', gui = 'bold' })
        else
          table.insert(label, { id .. ' ', group = 'Comment' })
        end
      end
      if #label > 0 then
        table.insert(label, 1, { '󰛢 ', group = 'Special' })
      end
      return label
    end

    return {
      hide = { cursorline = true },
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
        placement = { vertical = 'bottom', horizontal = 'center' },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then
          filename = '[No Name]'
        end
        local icon, icon_hl = require('mini.icons').get('file', filename)
        local fg = Snacks.util.color(icon_hl)
        local marks = harpoon_marks(props.buf)
        return {
          fg and { ' ', icon, ' ', guibg = fg, guifg = helpers.contrast_color(fg) } or { ' ', icon, ' ' },
          ' ',
          { filename, gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold' },
          ' ',
          #marks > 0 and { '│ ', group = 'Comment' } or '',
          marks,
        }
      end,
    }
  end,
}
