-- Sidekick: run / talk to any agent CLI (Codex, Claude, opencode, gemini, ...)
-- from Neovim and send it context ({this}, {file}, {selection}, diagnostics).
-- Copilot "Next Edit Suggestions" are off: Neovim is used to read and navigate
-- code here, not to type it, and NES needs the Copilot language server.
return {
  'folke/sidekick.nvim',
  ---@type sidekick.Config|{}
  opts = {
    nes = { enabled = false },
    cli = {
      watch = true, -- reload buffers when the CLI tools edit files
      mux = {
        backend = 'zellij',
        enabled = vim.fn.executable 'zellij' == 1,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { '<c-.>', function() require('sidekick.cli').toggle() end, desc = 'Sidekick Toggle', mode = { 'n', 't', 'i', 'x' } },
    { '<leader>aa', function() require('sidekick.cli').toggle() end, desc = 'Sidekick Toggle CLI' },
    { '<leader>as', function() require('sidekick.cli').select({ filter = { installed = true } }) end, desc = 'Select CLI' },
    { '<leader>ad', function() require('sidekick.cli').close() end, desc = 'Detach a CLI Session' },
    { '<leader>at', function() require('sidekick.cli').send({ msg = '{this}' }) end, mode = { 'x', 'n' }, desc = 'Send This' },
    { '<leader>af', function() require('sidekick.cli').send({ msg = '{file}' }) end, desc = 'Send File' },
    { '<leader>av', function() require('sidekick.cli').send({ msg = '{selection}' }) end, mode = { 'x' }, desc = 'Send Visual Selection' },
    { '<leader>ap', function() require('sidekick.cli').prompt() end, mode = { 'n', 'x' }, desc = 'Sidekick Select Prompt' },
    { '<leader>ax', function() require('sidekick.cli').send({ msg = '{diagnostics}' }) end, desc = 'Send Diagnostics' },
  },
}
