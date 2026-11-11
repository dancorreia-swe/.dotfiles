-- Line annotations / bookmarks that stay out of the file (great for reading code).
return {
  'TheNoeTrevino/haunt.nvim',
  ---@type HauntConfig
  opts = {
    sign = '󱙝',
    sign_hl = 'DiagnosticInfo',
    virt_text_hl = 'HauntAnnotation',
    annotation_prefix = ' 󰆉 ',
    virt_text_pos = 'eol',
    picker_keys = {
      delete = { key = 'd', mode = { 'n' } },
      edit_annotation = { key = 'a', mode = { 'n' } },
    },
  },
  -- load with the first file so saved annotations are restored, not at startup
  event = 'LazyFile',
  -- stylua: ignore
  keys = {
    { '<leader>ha', function() require('haunt.api').annotate() end, desc = 'Annotate' },
    { '<leader>ht', function() require('haunt.api').toggle_annotation() end, desc = 'Toggle annotation' },
    { '<leader>hT', function() require('haunt.api').toggle_all_lines() end, desc = 'Toggle all annotations' },
    { '<leader>hd', function() require('haunt.api').delete() end, desc = 'Delete bookmark' },
    { '<leader>hC', function() require('haunt.api').clear_all() end, desc = 'Delete all bookmarks' },
    { '<leader>hp', function() require('haunt.api').prev() end, desc = 'Previous bookmark' },
    { '<leader>hn', function() require('haunt.api').next() end, desc = 'Next bookmark' },
    { '<leader>hl', function() require('haunt.picker').show() end, desc = 'Show Picker' },
  },
}
