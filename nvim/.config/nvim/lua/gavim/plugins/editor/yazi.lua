---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '<leader>y',
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
    {
      -- NOTE: this requires a version of yazi that includes
      -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      '<leader>cj',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig
  opts = {
    -- directory buffers (`nvim .`, `:e dir/`) open the Snacks explorer instead
    open_for_directories = false,
    keymaps = {
      show_help = 'g?',
    },
  },
}
