local icons = {
  Error = { ' ', 'DiagnosticError' },
  Inactive = { ' ', 'MsgArea' },
  Warning = { ' ', 'DiagnosticWarn' },
  Normal = { '', 'Special' },
}

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    enabled = vim.g.have_nerd_font,
    { 'AndreM222/copilot-lualine' },
  },
  opts = {
    options = {
      section_separators = { left = '', right = '' },
      -- section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = {
        {
          'mode',
          fmt = function(mode)
            return '  ' .. mode
          end,
          separator = { left = '' },
          right_padding = 2,
          color = { gui = 'bold' },
        },
      },
      lualine_b = {
        'filename',
        'branch',
      },
      lualine_c = {
        {
          'diff',
          symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
        },
        {
          function()
            local status = require('sidekick.status').get()
            return status and vim.tbl_get(icons, status.kind, 1)
          end,
          cond = function()
            return require('sidekick.status').get() ~= nil
          end,
          color = function()
            local status = require('sidekick.status').get()
            local hl = status and (status.busy and 'DiagnosticWarn' or vim.tbl_get(icons, status.kind, 2))

            return { fg = Snacks.util.color(hl) }
          end,
        },
        '%=',
      },
      lualine_x = {
        {
          'copilot',
          show_colors = true,
        },
        {
          function()
            local msg = 'No Active Lsp'
            local buf_ft = vim.api.nvim_buf_get_option_value(0, 'filetype')
            local clients = vim.lsp.get_clients()
            if next(clients) == nil then
              return msg
            end
            for _, client in ipairs(clients) do
              local filetypes = client.config.filetypes
              if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
              end
            end
            return msg
          end,
          icon = ' LSP:',
          color = { fg = '#ffffff', gui = 'bold' },
        },
      },
      lualine_y = {
        {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          symbols = { error = ' ', warn = ' ', info = ' ' },
        },
        'filetype',
        'progress',
      },
      lualine_z = {
        { 'location', separator = { right = '' }, left_padding = 2 },
        -- { 'location', separator = { right = '' }, left_padding = 2 },
      },
    },
  },
}
