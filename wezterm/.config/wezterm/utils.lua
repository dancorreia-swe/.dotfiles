-- Shared utilities for WezTerm configuration
local M = {}

-- Cache for basename extraction to avoid repeated string operations
local basename_cache = {}

--- Extract the basename (filename) from a full path
---@param path string The full path
---@return string The basename
function M.basename(path)
  if not path then
    return ""
  end
  local cached = basename_cache[path]
  if cached then
    return cached
  end
  local name = path:match("[^/\\]+$") or path
  basename_cache[path] = name
  return name
end

--- Merge arrays (append second to first)
---@param base table|nil Base array
---@param additions table|nil Items to add
---@return table Merged array
function M.merge_arrays(base, additions)
  local result = base or {}
  if additions then
    for _, v in ipairs(additions) do
      table.insert(result, v)
    end
  end
  return result
end

--- Deep merge tables (for config objects)
---@param base table|nil Base table
---@param overrides table|nil Overrides to apply
---@return table Merged table
function M.merge_tables(base, overrides)
  local result = {}
  for k, v in pairs(base or {}) do
    result[k] = v
  end
  for k, v in pairs(overrides or {}) do
    result[k] = v
  end
  return result
end

return M
