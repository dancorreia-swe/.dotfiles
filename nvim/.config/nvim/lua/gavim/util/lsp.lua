---@class gavim.util.lsp
local M = {}

---Returns a callback that runs code actions of a specific LSP CodeActionKind.
---When a single action matches, it applies immediately (you named the intent by
---picking this keymap); multiple matches fall back to the picker.
---@param kind string  e.g. "source.organizeImports", "source.fixAll.ts"
---@return fun()
function M.run_action(kind)
  return function()
    vim.lsp.buf.code_action {
      apply = true,
      context = {
        only = { kind },
        diagnostics = {},
      },
    }
  end
end

---Opens the code-action picker filtered to source-level (whole-file) kinds.
---Never auto-applies — always shows the picker so you see what runs.
function M.pick_source_actions()
  vim.lsp.buf.code_action {
    context = {
      only = { 'source' },
      diagnostics = {},
    },
  }
end

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler
---@field filter? string|vim.lsp.get_clients.Filter
---@field title? string

---@param opts LspCommand
function M.execute(opts)
  local filter = opts.filter or {}
  filter = type(filter) == 'string' and { name = filter } or filter
  local buf = vim.api.nvim_get_current_buf()

  ---@cast filter vim.lsp.get_clients.Filter
  local client = vim.lsp.get_clients(GaVim.merge({}, filter, { bufnr = buf }))[1]

  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  if opts.open then
    require('trouble').open {
      mode = 'lsp_command',
      params = params,
    }
  else
    vim.list_extend(params, { title = opts.title })
    return client:exec_cmd(params, { bufnr = buf }, opts.handler)
  end
end

---@param list any[]
---@return any[]
local function dedup(list)
  local seen = {}
  return vim.tbl_filter(function(item)
    if seen[item] then
      return false
    end
    seen[item] = true
    return true
  end, list)
end

---@param filter? vim.lsp.get_clients.Filter
---@return string[]
function M.code_actions(filter)
  filter = filter or {}
  local ret = {} ---@type string[]
  local clients = vim.lsp.get_clients(filter)
  for _, client in ipairs(clients) do
    vim.list_extend(ret, vim.tbl_get(client, 'server_capabilities', 'codeActionProvider', 'codeActionKinds') or {})
    local regs = client.dynamic_capabilities:get('codeActionProvider', filter)
    for _, reg in ipairs(regs or {}) do
      vim.list_extend(ret, vim.tbl_get(reg, 'registerOptions', 'codeActionKinds') or {})
    end
  end
  return dedup(ret)
end

return M
