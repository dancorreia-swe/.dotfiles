-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
local function augroup(name)
  return vim.api.nvim_create_augroup('gvim_' .. name, { clear = true })
end

-- Check if we need to reload the file when it changed.
-- Agents edit files on disk from other terminals, so besides focus events we
-- also check on buffer enter / cursor idle, and gavim.util.watch triggers a
-- check as soon as a watched file changes.
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave', 'BufEnter', 'CursorHold' }, {
  group = augroup 'checktime',
  callback = function()
    if vim.o.buftype ~= 'nofile' and vim.fn.getcmdwintype() == '' then
      pcall(vim.cmd.checktime)
    end
  end,
})

-- Decide what happens when a file changed on disk, without blocking prompts:
-- * unmodified buffer -> reload silently (the common "agent edited it" case)
-- * modified buffer   -> keep your text, mark the conflict and warn once
vim.api.nvim_create_autocmd('FileChangedShell', {
  group = augroup 'file_changed',
  callback = function(event)
    local buf = event.buf
    local name = vim.fn.fnamemodify(event.file, ':~:.')
    if vim.v.fcs_reason == 'deleted' then
      vim.v.fcs_choice = ''
      vim.b[buf].gavim_disk_conflict = true
      vim.notify(('`%s` was deleted on disk'):format(name), vim.log.levels.WARN, { title = 'File changed' })
    elseif vim.bo[buf].modified then
      vim.v.fcs_choice = ''
      if not vim.b[buf].gavim_disk_conflict then
        vim.b[buf].gavim_disk_conflict = true
        vim.notify(
          ('`%s` changed on disk but has unsaved edits.\n`:e!` to load the disk version, `:w!` to overwrite it.'):format(name),
          vim.log.levels.WARN,
          { title = 'File changed' }
        )
      end
    else
      vim.v.fcs_choice = 'reload'
    end
  end,
})
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  group = augroup 'file_changed_reset',
  callback = function(event)
    vim.b[event.buf].gavim_disk_conflict = nil
  end,
})

-- Watch directories of open files so external edits show up immediately.
require('gavim.util.watch').setup()

-- Auto save modified files when focus is lost or the buffer is hidden.
-- Skips buffers whose file changed on disk meanwhile, so an agent's edits are
-- never silently overwritten (and no "file changed" prompt blocks the UI).
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  desc = 'Auto save files when focus is lost or buffer is hidden',
  group = augroup 'autosave',
  callback = function()
    pcall(vim.cmd.checktime) -- flags disk conflicts via FileChangedShell above
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].modified
        and vim.bo[buf].buftype == ''
        and vim.bo[buf].modifiable
        and not vim.bo[buf].readonly
        and not vim.b[buf].gavim_disk_conflict
        and vim.api.nvim_buf_get_name(buf) ~= ''
      then
        vim.api.nvim_buf_call(buf, function()
          pcall(vim.cmd, 'silent update')
        end)
      end
    end
  end,
})

-- Quick-edit mode (Neovim opened as $EDITOR by Claude Code, Codex, git, jj...):
-- prose-friendly settings and <C-s> to save and hand the text back.
if vim.g.gavim_quick_edit then
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = augroup 'quick_edit',
    once = true,
    callback = function(event)
      vim.b[event.buf].autoformat = false
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.spell = true
      vim.opt_local.cursorcolumn = false
      vim.keymap.set({ 'n', 'i', 'x' }, '<C-s>', '<cmd>wq<cr>', { buffer = event.buf, desc = 'Save and Return to Caller' })
    end,
  })
end

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = augroup 'resize_splits',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup 'last_loc',
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].gavim_last_loc then
      return
    end
    vim.b[buf].gavim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup 'auto_create_dir',
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'wrap_spell',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = augroup 'json_conceal',
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'man_unlisted',
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})
