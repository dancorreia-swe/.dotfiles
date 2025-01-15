-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto save files when focus is lost
vim.api.nvim_create_autocmd('FocusLost', {
  desc = 'Auto save files when focus is lost',
  group = vim.api.nvim_create_augroup('kickstart-autosave', { clear = true }),
  callback = function()
    vim.cmd 'silent! wa'
  end,
})

-- Auto save files when buffer is hidden
vim.api.nvim_create_autocmd('BufLeave', {
  desc = 'Auto save files when buffer is hidden',
  group = vim.api.nvim_create_augroup('kickstart-autosave', { clear = false }),
  callback = function()
    vim.cmd 'silent! wa'
  end,
})
