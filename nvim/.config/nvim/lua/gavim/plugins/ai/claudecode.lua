-- Claude Code IDE integration (same protocol the VS Code / JetBrains extensions use).
--
-- Neovim runs a local WebSocket server and writes a lock file to ~/.claude/ide/.
-- A `claude` started anywhere in the same project (Orca, zellij, another
-- terminal) picks it up automatically or via `/ide`, and then:
--   * sees the file / selection you're looking at as context
--   * can open its proposed edits as diffs here for you to accept / deny
--   * can read LSP diagnostics from this Neovim
-- Not started in quick-edit mode, so the $EDITOR instance Claude Code opens for
-- prompt editing never registers itself as a second IDE.
return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cond = not vim.g.gavim_quick_edit,
  -- the server must be up before Claude connects, so don't wait for a keypress
  event = 'VeryLazy',
  cmd = { 'ClaudeCode', 'ClaudeCodeStart', 'ClaudeCodeStatus', 'ClaudeCodeAdd', 'ClaudeCodeSend' },
  opts = {
    -- `claude` launched from inside Neovim (<leader>ac) uses a Snacks terminal;
    -- Claude running in an external terminal works the same through `/ide`.
    terminal = {
      provider = 'snacks',
      split_side = 'right',
      split_width_percentage = 0.4,
    },
    diff_opts = {
      layout = 'vertical',
      open_in_new_tab = true, -- review proposed edits in their own tab
      hide_terminal_in_new_tab = true,
    },
  },
  -- stylua: ignore
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Claude Code (toggle)' },
    { '<leader>ac', '<cmd>ClaudeCodeSend<cr>', mode = 'x', desc = 'Send Selection to Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Claude Code (continue)' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add Buffer to Claude' },
    { '<leader>ab', '<cmd>ClaudeCodeTreeAdd<cr>', desc = 'Add File to Claude', ft = { 'snacks_picker_list', 'yazi' } },
    { '<leader>ay', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept Claude Diff' },
    { '<leader>an', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny Claude Diff' },
    { '<leader>aS', '<cmd>ClaudeCodeStatus<cr>', desc = 'Claude Code Status' },
  },
}
