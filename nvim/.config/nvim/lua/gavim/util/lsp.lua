---@class gavim.util.lsp
local M = {}

---@param opts? lsp.Client.format
function M.format(opts)
  opts = vim.tbl_deep_extend('force', {}, opts or {}, GaVim.opts('nvim-lspconfig').format or {})
  local ok, conform = pcall(require, 'conform')
  -- use conform for formatting with LSP when available,
  -- since it has better format diffing
  if ok then
    -- It should be `nil`, otherwise it doesn't fetch options from `formatters_by_ft`,
    -- see https://github.com/stevearc/conform.nvim/blob/5420c4b5ea0aeb99c09cfbd4fd0b70d257b44f25/lua/conform/init.lua#L417-L418
    opts.formatters = nil
    conform.format(opts)
  else
    vim.lsp.buf.format(opts)
  end
end

M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action {
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      }
    end
  end,
})

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

return M
