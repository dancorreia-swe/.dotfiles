---@class gavim.util.watch
--- Reload buffers as soon as their files change on disk.
---
--- Agents (Claude Code, Codex, ...) usually run in another terminal and write
--- files directly. `autoread` alone only reacts on focus/cursor events, so we
--- watch the directory of every loaded file buffer with libuv fs events and
--- run a debounced `:checktime` whenever something in there changes.
local M = {}

M.watches = {} ---@type table<string, uv.uv_fs_event_t>
M.debounce_ms = 150

local timer = assert(vim.uv.new_timer())

local function refresh()
  timer:stop()
  timer:start(
    M.debounce_ms,
    0,
    vim.schedule_wrap(function()
      -- `:checktime` is not allowed in the cmdline window or while typing a command.
      local mode = vim.api.nvim_get_mode().mode
      if vim.fn.getcmdwintype() ~= '' or mode:sub(1, 1) == 'c' then
        return refresh()
      end
      pcall(vim.cmd.checktime)
    end)
  )
end

---@param buf integer
---@return string?
local function dirname(buf)
  if not (vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '') then
    return
  end
  local fname = vim.api.nvim_buf_get_name(buf)
  if fname == '' or fname:match '^%w%w+://' or not vim.uv.fs_stat(fname) then
    return
  end
  return vim.fs.dirname(fname)
end

---@param path string
local function start(path)
  if M.watches[path] then
    return
  end
  local w = vim.uv.new_fs_event()
  if not w then
    return
  end
  local ok = w:start(path, {}, function(err, file)
    if not err and file then
      refresh()
    end
  end)
  if ok then
    M.watches[path] = w
  elseif not w:is_closing() then
    w:close()
  end
end

--- Sync watches with the set of directories of loaded file buffers.
function M.update()
  local dirs = {} ---@type table<string, boolean>
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local dir = dirname(buf)
    if dir then
      dirs[dir] = true
    end
  end
  for dir in pairs(dirs) do
    start(dir)
  end
  for dir, w in pairs(M.watches) do
    if not dirs[dir] then
      if not w:is_closing() then
        w:stop()
        w:close()
      end
      M.watches[dir] = nil
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('gavim_watch', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'BufDelete', 'BufWipeout', 'BufUnload' }, {
    group = group,
    callback = function()
      -- defer so the buffer list reflects the event
      vim.schedule(M.update)
    end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      for _, w in pairs(M.watches) do
        if not w:is_closing() then
          w:stop()
          w:close()
        end
      end
      M.watches = {}
    end,
  })
  M.update()
end

return M
