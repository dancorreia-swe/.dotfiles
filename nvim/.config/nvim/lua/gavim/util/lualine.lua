---@class gavim.util.lualine
local M = {}

-- Cache for VCS info - invalidated by autocmds, not time-based
---@type { type: "git"|"jj"|nil, revision: string?, bookmarks: string?, branch: string?, valid: boolean }
local vcs_cache = { valid = false }

---@return boolean
local function is_jj_repo()
  local cwd = vim.fn.getcwd()
  local jj_dir = vim.fs.find('.jj', { upward = true, path = cwd, type = 'directory' })
  return #jj_dir > 0
end

---@return string?
local function get_jj_revision()
  local result = vim.fn.systemlist 'jj log -r @ --no-graph -T "change_id.shortest()"'
  if vim.v.shell_error == 0 and result[1] then
    return result[1]
  end
  return nil
end

---@return string?
local function get_jj_bookmarks()
  local result = vim.fn.systemlist 'jj log -r "closest_bookmark(@)" --no-graph -T "bookmarks.join(\\", \\")"'
  if vim.v.shell_error == 0 and result[1] and result[1] ~= '' then
    return result[1]
  end
  return nil
end

---@return string?
local function get_git_branch()
  local result = vim.fn.systemlist 'git branch --show-current'
  if vim.v.shell_error == 0 and result[1] then
    return result[1]
  end
  return nil
end

local function refresh_vcs_cache()
  if is_jj_repo() then
    vcs_cache.type = 'jj'
    vcs_cache.revision = get_jj_revision()
    vcs_cache.bookmarks = get_jj_bookmarks()
    vcs_cache.branch = nil
  else
    vcs_cache.type = 'git'
    vcs_cache.branch = get_git_branch()
    vcs_cache.revision = nil
    vcs_cache.bookmarks = nil
  end
  vcs_cache.valid = true
end

--- Invalidate cache (called by autocmds)
function M.invalidate_vcs_cache()
  vcs_cache.valid = false
end

-- Setup autocmds to invalidate cache on relevant events
local function setup_vcs_autocmds()
  local group = vim.api.nvim_create_augroup('GaVimVcsCache', { clear = true })

  vim.api.nvim_create_autocmd({ 'DirChanged', 'FocusGained', 'TermLeave', 'ShellCmdPost' }, {
    group = group,
    callback = M.invalidate_vcs_cache,
  })

  -- Also refresh when entering a buffer in a different directory
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function()
      -- Only invalidate if buffer is in a different directory
      local buf_dir = vim.fn.expand '%:p:h'
      if buf_dir ~= '' and vim.fn.isdirectory(buf_dir) == 1 then
        M.invalidate_vcs_cache()
      end
    end,
  })
end

-- Initialize autocmds once
local autocmds_initialized = false

---Creates a lualine component that shows jujutsu revision/bookmarks or git branch
---@param opts? { jj_icon?: string, git_icon?: string, bookmark_icon?: string }
function M.vcs(opts)
  opts = vim.tbl_extend('force', {
    jj_icon = '', -- nf-fa-code_fork (same as ohmyposh \uf1fa)
    git_icon = '', -- git branch icon
    bookmark_icon = '󰃀', -- bookmark icon
  }, opts or {})

  -- Setup autocmds on first use
  if not autocmds_initialized then
    setup_vcs_autocmds()
    autocmds_initialized = true
  end

  return {
    function()
      if not vcs_cache.valid then
        refresh_vcs_cache()
      end

      if vcs_cache.type == 'jj' then
        local parts = {}
        if vcs_cache.revision then
          table.insert(parts, opts.jj_icon .. ' ' .. vcs_cache.revision)
        end
        if vcs_cache.bookmarks then
          table.insert(parts, opts.bookmark_icon .. ' ' .. vcs_cache.bookmarks)
        end
        return table.concat(parts, ' ')
      elseif vcs_cache.type == 'git' and vcs_cache.branch then
        return opts.git_icon .. ' ' .. vcs_cache.branch
      end

      return ''
    end,
    cond = function()
      if not vcs_cache.valid then
        refresh_vcs_cache()
      end
      return vcs_cache.type ~= nil
    end,
    color = function()
      if vcs_cache.type == 'jj' then
        return { fg = Snacks.util.color 'String' } -- yellowish for jj
      end
      return nil -- use default for git
    end,
  }
end

---@param icon string
---@param status fun(): nil|"ok"|"error"|"pending"
function M.status(icon, status)
  local colors = {
    ok = 'Special',
    error = 'DiagnosticError',
    pending = 'DiagnosticWarn',
  }
  return {
    function()
      return icon
    end,
    cond = function()
      return status() ~= nil
    end,
    color = function()
      return { fg = Snacks.util.color(colors[status()] or colors.ok) }
    end,
  }
end

---@param name string
---@param icon? string
function M.cmp_source(name, icon)
  icon = icon or GaVim.icons.icons.kinds[name:sub(1, 1):upper() .. name:sub(2)]
  local started = false
  return M.status(icon, function()
    if not package.loaded['cmp'] then
      return
    end
    for _, s in ipairs(require('cmp').core.sources or {}) do
      if s.name == name then
        if s.source:is_available() then
          started = true
        else
          return started and 'error' or nil
        end
        if s.status == s.SourceStatus.FETCHING then
          return 'pending'
        end
        return 'ok'
      end
    end
  end)
end

---@param component any
---@param text string
---@param hl_group? string
---@return string
function M.format(component, text, hl_group)
  text = text:gsub('%%', '%%%%')
  if not hl_group or hl_group == '' then
    return text
  end
  ---@type table<string, string>
  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]
  if not lualine_hl_group then
    local utils = require 'lualine.utils.utils'
    ---@type string[]
    local gui = vim.tbl_filter(function(x)
      return x
    end, {
      utils.extract_highlight_colors(hl_group, 'bold') and 'bold',
      utils.extract_highlight_colors(hl_group, 'italic') and 'italic',
    })

    lualine_hl_group = component:create_hl({
      fg = utils.extract_highlight_colors(hl_group, 'fg'),
      gui = #gui > 0 and table.concat(gui, ',') or nil,
    }, 'LV_' .. hl_group) --[[@as string]]
    component.hl_cache[hl_group] = lualine_hl_group
  end
  return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
function M.pretty_path(opts)
  opts = vim.tbl_extend('force', {
    relative = 'cwd',
    modified_hl = 'MatchParen',
    directory_hl = '',
    filename_hl = 'Bold',
    modified_sign = '',
    readonly_icon = ' 󰌾 ',
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand '%:p' --[[@as string]]

    if path == '' then
      return ''
    end

    path = vim.fs.normalize(path)
    local root = GaVim.root { normalize = true }
    local cwd = GaVim.root.cwd()

    -- original path is preserved to provide user with expected result of pretty_path, not a normalized one,
    -- which might be confusing
    local norm_path = path

    if GaVim.is_win() then
      -- in case any of the provided paths involved mixed case, an additional normalization step for windows
      norm_path = norm_path:lower()
      root = root:lower()
      cwd = cwd:lower()
    end

    if opts.relative == 'cwd' and norm_path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    elseif norm_path:find(root, 1, true) == 1 then
      path = path:sub(#root + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, '[\\/]')

    if opts.length == 0 then
      parts = parts
    elseif #parts > opts.length then
      parts = { parts[1], '…', unpack(parts, #parts - opts.length + 2, #parts) }
    end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = M.format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ''
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = M.format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ''
    if vim.bo.readonly then
      readonly = M.format(self, opts.readonly_icon, opts.modified_hl)
    end
    return dir .. parts[#parts] .. readonly
  end
end

---@param opts? {cwd:false, subdirectory: true, parent: true, other: true, icon?:string}
function M.root_dir(opts)
  opts = vim.tbl_extend('force', {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = '󱉭 ',
    color = function()
      return { fg = Snacks.util.color 'Special' }
    end,
  }, opts or {})

  local function get()
    local cwd = GaVim.root.cwd()
    local root = GaVim.root { normalize = true }
    local name = vim.fs.basename(root)

    if root == cwd then
      -- root is cwd
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      -- root is subdirectory of cwd
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      -- root is parent directory of cwd
      return opts.parent and name
    else
      -- root and cwd are not related
      return opts.other and name
    end
  end

  return {
    function()
      return (opts.icon and opts.icon .. ' ') .. get()
    end,
    cond = function()
      return type(get()) == 'string'
    end,
    color = opts.color,
  }
end

return M
