-- check snacks config (<leader>jj)
if true then
  return {}
end

return {
  'nicolasgb/jj.nvim',
  opts = {
    terminal = {
      cursor_render_delay = 10, -- Adjust if cursor position isn't restoring correctly
    },
    cmd = {
      describe = {
        editor = {
          type = 'buffer',
          keymaps = {
            close = { 'q', '<Esc>', '<C-c>' },
          },
        },
      },
      bookmark = {
        prefix = 'feat/',
      },
      keymaps = {
        log = {
          checkout = '<CR>',
          describe = 'd',
          diff = '<S-d>',
          abandon = '<S-a>',
          fetch = '<S-f>',
        },
        status = {
          open_file = '<CR>',
          restore_file = '<S-x>',
        },
        close = { 'q', '<Esc>' },
      },
    },
    highlights = {
      modified = { fg = '#89ddff' },
    },
  },
  -- stylua: ignore
  keys = {
    -- Core commands
    { '<leader>jd', function() require('jj.cmd').describe() end, desc = 'JJ describe' },
    { '<leader>jl', function() require('jj.cmd').log() end, desc = 'JJ log' },
    { '<leader>je', function() require('jj.cmd').edit() end, desc = 'JJ edit' },
    { '<leader>jn', function() require('jj.cmd').new() end, desc = 'JJ new' },
    { '<leader>js', function() require('jj.cmd').status() end, desc = 'JJ status' },
    { '<leader>sj', function() require('jj.cmd').squash() end, desc = 'JJ squash' },
    { '<leader>ju', function() require('jj.cmd').undo() end, desc = 'JJ undo' },
    { '<leader>jy', function() require('jj.cmd').redo() end, desc = 'JJ redo' },
    { '<leader>jr', function() require('jj.cmd').rebase() end, desc = 'JJ rebase' },
    { '<leader>jbc', function() require('jj.cmd').bookmark_create() end, desc = 'JJ bookmark create' },
    { '<leader>jbd', function() require('jj.cmd').bookmark_delete() end, desc = 'JJ bookmark delete' },
    { '<leader>jbm', function() require('jj.cmd').bookmark_move() end, desc = 'JJ bookmark move' },
    { '<leader>ja', function() require('jj.cmd').abandon() end, desc = 'JJ abandon' },
    { '<leader>jf', function() require('jj.cmd').fetch() end, desc = 'JJ fetch' },
    { '<leader>jP', function() require('jj.cmd').push() end, desc = 'JJ push' },
    { '<leader>jpr', function() require('jj.cmd').open_pr() end, desc = 'JJ open PR from bookmark in current revision or parent' },
    { '<leader>jpl', function() require('jj.cmd').open_pr { list_bookmarks = true } end, desc = 'JJ open PR listing available bookmarks' },
    -- Log with parameters
    { '<leader>jL', function() require('jj.cmd').log { revisions = "'all()'" } end, desc = 'JJ log all' },
    -- Tug alias
    { '<leader>jt', function()
      local cmd = require('jj.cmd')
      cmd.j('tug')
      cmd.log {}
    end, desc = 'JJ tug' },
    -- Diff commands
    { '<leader>df', function() require('jj.diff').open_vdiff() end, desc = 'JJ diff current buffer' },
    { '<leader>dF', function() require('jj.diff').open_hdiff() end, desc = 'JJ hdiff current buffer' },
    -- Pickers
    { '<leader>gj', function() require('jj.picker').status() end, desc = 'JJ Picker status' },
    { '<leader>jgh', function() require('jj.picker').file_history() end, desc = 'JJ Picker history' },
  },
}
