---@class gavim.util: LazyUtilCore
---@field icons gavim.util.icons
---@field lsp gavim.util.lsp
---@field plugin gavim.util.plugin
---@field cmp gavim.util.cmp
---@field lualine gavim.util.lualine
---@field treesitter gavim.util.treesitter
local M = {}

setmetatable(M, {
  __call = function(m, ...)
    return m.get(...)
  end,
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require('util.' .. k)
    return t[k]
  end,
})

M.cache = {}

M.detectors = {}

M.spec = { 'lsp', { '.git', 'lua' }, 'cwd' }

function M.is_win()
  return vim.uv.os_uname().sysname:find 'Windows' ~= nil
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes('<c-G>u', true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == 'i' then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, 'n', false)
  end
end

function M.detectors.cwd()
  return { vim.uv.cwd() }
end

function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients { bufnr = buf }
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients) --[[@as vim.lsp.Client[] ]]
  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end
  return vim.tbl_filter(function(path)
    path = vim.fs.normalize(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == 'string' and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then
        return true
      end
      if p:sub(1, 1) == '*' and name:find(vim.pesc(p:sub(2)) .. '$') then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == 'function' then
    return spec
  end
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == 'table' and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    paths = type(paths) == 'table' and paths or { paths }
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

function M.getRootDir(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]

  if not ret then
    local roots = M.detect { all = false, buf = buf }
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end

  if opts and opts.normalize then
    return ret
  end
  return M.is_win() and ret:gsub('/', '\\') or ret
end

function M.realpath(path)
  if path == '' or path == nil then
    return nil
  end

  path = vim.uv.fs_realpath(path) or path
  return vim.fs.normalize(path)
end

function M.cwd()
  return M.realpath(vim.uv.cwd()) or ''
end

---@param name string
function M.get_plugin(name)
  return require('lazy.core.config').spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end

  local Plugin = require 'lazy.core.plugin'
  return Plugin.values(plugin, 'opts', false)
end

for _, level in ipairs { 'info', 'warn', 'error' } do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or 'GaVim'
    return require('lazy.core.util')[level](msg, opts)
  end
end

local _defaults = {} ---@type table<string, boolean>

-- Determines whether it's safe to set an option to a default value.
--
-- It will only set the option if:
-- * it is the same as the global value
-- * it's current value is a default value
-- * it was last set by a script in $VIMRUNTIME
---@param option string
---@param value string|number|boolean
---@return boolean was_set
function M.set_default(option, value)
  local l = vim.api.nvim_get_option_value(option, { scope = 'local' })
  local g = vim.api.nvim_get_option_value(option, { scope = 'global' })

  _defaults[('%s=%s'):format(option, value)] = true
  local key = ('%s=%s'):format(option, l)

  local source = ''
  if l ~= g and not _defaults[key] then
    -- Option does not match global and is not a default value
    -- Check if it was set by a script in $VIMRUNTIME
    local info = vim.api.nvim_get_option_info2(option, { scope = 'local' })
    ---@param e vim.fn.getscriptinfo.ret
    local scriptinfo = vim.tbl_filter(function(e)
      return e.sid == info.last_set_sid
    end, vim.fn.getscriptinfo())
    source = scriptinfo[1] and scriptinfo[1].name or ''
    local by_rtp = #scriptinfo == 1 and vim.startswith(scriptinfo[1].name, vim.fn.expand '$VIMRUNTIME')
    if not by_rtp then
      if vim.g.lazyvim_debug_set_default then
        print(('Current value: `%q`, global value: `%q`, set by: `%s`'):format(l, g, source))
      end
      return false
    end
  end

  vim.api.nvim_set_option_value(option, value, { scope = 'local' })
  return true
end

return M
