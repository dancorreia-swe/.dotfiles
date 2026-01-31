if true then
  return {}
end

return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'BufReadPost',
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = false,
          next = '<M-]>',
          prev = '<M-[>',
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    opts = function()
      GaVim.cmp.actions.ai_accept = function()
        if require('copilot.suggestion').is_visible() then
          GaVim.create_undo()
          require('copilot.suggestion').accept()

          return true
        end
      end
    end,
  },
}
