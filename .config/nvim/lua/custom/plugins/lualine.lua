return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font, { 'AndreM222/copilot-lualine' } },
  config = function()
    require('lualine').setup {
      options = {
        section_separators = { left = '', right = '' },
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
          '%=',
        },
        lualine_x = {
          'copilot',
          {
            function()
              local msg = 'No Active Lsp'
              local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
              local clients = vim.lsp.get_active_clients()
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
        },
      },
      inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
      },
    }
  end,
}
