return {
  'nmac427/guess-indent.nvim',
  config = function()
    require('guess-indent').setup {
      auto_cmd = true, -- Set to false to disable automatic execution
      override_editorconfig = false,
      filetype_exclude = { -- A list of filetypes for which the auto command gets disabled
        'netrw',
        'tutor',
      },
      buftype_exclude = {
        'help',
        'nofile',
        'terminal',
        'prompt',
      },

      vim.api.nvim_create_autocmd('VimEnter', {
        group = vim.api.nvim_create_augroup('GuessIndent', { clear = true }),
        command = "autocmd BufReadPost * :silent lua require('guess-indent').set_from_buffer(true)",
      }),
    }
  end,
} -- Detect tabstop and shiftwidth automatially
