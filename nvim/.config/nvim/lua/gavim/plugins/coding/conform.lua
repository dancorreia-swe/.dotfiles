--- Only use prettier when the project is configured for it, so files edited by
--- agents/CI are never reformatted with a style the project doesn't use.
---@param ctx conform.Context
local function has_prettier_config(ctx)
  local found = vim.fs.find({
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.json5',
    '.prettierrc.yaml',
    '.prettierrc.yml',
    '.prettierrc.toml',
    '.prettierrc.js',
    '.prettierrc.cjs',
    '.prettierrc.mjs',
    '.prettierrc.ts',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
    'prettier.config.ts',
  }, { path = ctx.dirname, upward = true })[1]
  if found then
    return true
  end
  local pkg = vim.fs.find('package.json', { path = ctx.dirname, upward = true })[1]
  if pkg then
    local ok, data = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(pkg), '\n'))
    end)
    return ok and type(data) == 'table' and data.prettier ~= nil
  end
  return false
end

---@param ctx conform.Context
local function has_biome_config(ctx)
  return vim.fs.find({ 'biome.json', 'biome.jsonc' }, { path = ctx.dirname, upward = true })[1] ~= nil
end

local web = { 'biome', 'prettierd', 'prettier', stop_after_first = true }

return {
  'stevearc/conform.nvim',
  dependencies = { 'mason.nvim' },
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo', 'Format' },
  keys = {
    {
      '<leader>F',
      function()
        require('conform').format { async = true }
      end,
      mode = { 'n', 'x' },
      desc = 'Format buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    default_format_opts = {
      timeout_ms = 3000,
      async = false, -- not recommended to change
      quiet = false, -- not recommended to change
      lsp_format = 'fallback', -- not recommended to change
    },
    log_level = vim.log.levels.WARN,
    format_on_save = function(bufnr)
      if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
        return
      end
      -- Don't fall back to LSP formatting for languages without a
      -- well standardized coding style.
      local no_lsp_fallback = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_format = no_lsp_fallback[vim.bo[bufnr].filetype] and 'never' or 'fallback',
      }
    end,

    formatters_by_ft = {
      lua = { 'stylua' },
      php = { 'pint', 'php_cs_fixer', stop_after_first = true },
      javascript = web,
      typescript = web,
      typescriptreact = web,
      javascriptreact = web,
      json = web,
      jsonc = web,
      css = web,
      html = { 'prettierd', 'prettier', stop_after_first = true },
      toml = { 'taplo' },
    },

    formatters = {
      injected = { options = { ignore_errors = true } },
      biome = { condition = has_biome_config },
      prettier = { condition = has_prettier_config },
      prettierd = { condition = has_prettier_config },
      taplo = {
        args = { 'format', '--option', 'indent_entries=true', '-o', 'indent_tables=true', '-' },
      },
    },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.api.nvim_create_user_command('Format', function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ['end'] = { args.line2, end_line:len() },
        }
      end
      require('conform').format { async = true, lsp_format = 'fallback', range = range }
    end, { range = true, desc = 'Format buffer or range' })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      once = true,
      callback = function()
        Snacks.toggle({
          name = 'Auto Format (Global)',
          get = function()
            return vim.g.autoformat ~= false
          end,
          set = function(state)
            vim.g.autoformat = state
          end,
        }):map '<leader>uf'
        Snacks.toggle({
          name = 'Auto Format (Buffer)',
          get = function()
            return vim.g.autoformat ~= false and vim.b.autoformat ~= false
          end,
          set = function(state)
            vim.b.autoformat = state
          end,
        }):map '<leader>uF'
      end,
    })
  end,
}
