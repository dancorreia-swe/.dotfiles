return {
  'nicolasgb/jj.nvim',
  branch = 'main',
  event = 'VeryLazy',
  dependencies = {
    'esmuellert/codediff.nvim',
    'folke/snacks.nvim',
  },
  opts = {
    terminal = {
      cursor_render_delay = 10,
    },
    editor = {
      auto_insert = true,
    },
    diff = {
      backend = 'codediff',
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
        prefix = 'dancorreia-swe/',
      },
      keymaps = {
        log = {
          edit = '<CR>',
          describe = 'd',
          diff = '<S-d>',
          abandon = '<S-a>',
          fetch = '<S-f>',
          change_revset = 'r',
        },
        status = {
          open_file = '<CR>',
          restore_file = '<S-x>',
        },
        close = { 'q', '<Esc>' },
      },
    },
    highlights = {
      editor = {
        modified = { fg = '#89ddff' },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { '<leader>jd', function() require('jj.cmd').describe() end, desc = 'JJ describe' },
    { '<leader>jl', function() require('jj.cmd').log() end, desc = 'JJ log' },
    {
      '<leader>jL',
      function() require('jj.cmd').log { revisions = "'all()'" } end,
      desc = 'JJ log all',
    },
    { '<leader>je', function() require('jj.cmd').edit() end, desc = 'JJ edit' },
    { '<leader>jn', function() require('jj.cmd').new() end, desc = 'JJ new' },
    { '<leader>js', function() require('jj.cmd').status() end, desc = 'JJ status' },
    { '<leader>jS', function() require('jj.cmd').squash() end, desc = 'JJ squash' },
    { '<leader>ju', function() require('jj.cmd').undo() end, desc = 'JJ undo' },
    { '<leader>jy', function() require('jj.cmd').redo() end, desc = 'JJ redo' },
    { '<leader>jr', function() require('jj.cmd').rebase() end, desc = 'JJ rebase' },
    { '<leader>jx', function() require('jj.cmd').abandon() end, desc = 'JJ abandon' },
    { '<leader>jc', function() require('jj.cmd').commit() end, desc = 'JJ commit (finalize)' },
    { '<leader>jbc', function() require('jj.cmd').bookmark_create() end, desc = 'JJ bookmark create' },
    { '<leader>jbm', function() require('jj.cmd').bookmark_move() end, desc = 'JJ bookmark move' },
    { '<leader>jbd', function() require('jj.cmd').bookmark_delete() end, desc = 'JJ bookmark delete' },
    { '<leader>jbt', function() require('jj.cmd').bookmark_track() end, desc = 'JJ bookmark track' },
    { '<leader>jbf', function() require('jj.cmd').bookmark_forget() end, desc = 'JJ bookmark forget' },
    { '<leader>jgf', function() require('jj.cmd').fetch() end, desc = 'JJ fetch' },
    { '<leader>jgp', function() require('jj.cmd').push() end, desc = 'JJ push' },
    { '<leader>jgP', function() require('jj.cmd').open_pr() end, desc = 'JJ open PR' },
    { '<leader>jgr', function() require('jj.cmd').fetch_pr() end, desc = 'JJ fetch PR' },
    { '<leader>jTs', function() require('jj.cmd').tag_set() end, desc = 'JJ tag set' },
    { '<leader>jTd', function() require('jj.cmd').tag_delete() end, desc = 'JJ tag delete' },
    { '<leader>jTp', function() require('jj.cmd').tag_push() end, desc = 'JJ tag push' },
    { '<leader>jf', function() require('jj.diff').open_vdiff() end, desc = 'JJ diff buffer (vertical)' },
    { '<leader>jF', function() require('jj.diff').open_hdiff() end, desc = 'JJ diff buffer (horizontal)' },
    { '<leader>jh', function() require('jj.cmd').diff_history() end, desc = 'JJ diff history' },
    {
      '<leader>jD',
      function()
        local diff = require 'jj.diff'
        local function run(rev)
          if not rev or rev == '' then return end
          local left, right = rev:match '^(.-)%.%.(.*)$'
          if left then
            diff.diff_revisions {
              left = left ~= '' and left or '@-',
              right = right ~= '' and right or '@',
            }
          else
            diff.show_revision { rev = rev }
          end
        end
        local presets = {
          '@-',
          '@-..@',
          'trunk()..@',
          'main..@',
          '@--..@-',
          'Custom...',
        }
        vim.ui.select(presets, {
          prompt = 'JJ diff revset',
          format_item = function(item)
            local hints = {
              ['@-']        = '@-          parent of working copy',
              ['@-..@']     = '@-..@       working-copy changes',
              ['trunk()..@']= 'trunk()..@  branch vs trunk',
              ['main..@']   = 'main..@     branch vs main',
              ['@--..@-']   = '@--..@-     previous commit',
              ['Custom...'] = 'Custom...   free-form revset',
            }
            return hints[item] or item
          end,
        }, function(choice)
          if not choice then return end
          if choice == 'Custom...' then
            vim.ui.input({ prompt = 'JJ revset: ', default = '@-..@' }, run)
          else
            run(choice)
          end
        end)
      end,
      desc = 'JJ diff revset',
    },
    { '<leader>jps', function() require('jj.picker').status() end, desc = 'JJ picker status' },
    { '<leader>jph', function() require('jj.picker').file_history() end, desc = 'JJ picker file history' },
    { '<leader>ja',  function() require('jj.annotate').file() end, desc = 'JJ annotate file' },
    { '<leader>jA',  function() require('jj.annotate').line() end, desc = 'JJ annotate line' },
    {
      '<leader>jt',
      function()
        local cmd = require('jj.cmd')
        cmd.j 'tug'
        cmd.log {}
      end,
      desc = 'JJ tug',
    },
  },
}
