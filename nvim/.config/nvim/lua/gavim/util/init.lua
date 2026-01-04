---@class gavim.util: LazyUtilCore
---@field icons gavim.util.icons
---@field lsp gavim.util.lsp
---@field plugin gavim.util.plugin
---@field cmp gavim.util.cmp
---@field lualine gavim.util.lualine
---@field treesitter gavim.util.treesitter
---@field root gavim.util.root
local M = {}

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require('gavim.util.' .. k)
    return t[k]
  end,
})

function M.is_win()
  return vim.uv.os_uname().sysname:find 'Windows' ~= nil
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes('<c-G>u', true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == 'i' then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, 'n', false)
  end
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
