---@alias gavim.TSFeat { enable?: boolean, disable?: string[] }

return {
  -- Treesitter is a new parser generator tool that we can
  -- use in Neovim to power faster and more accurate
  -- syntax highlighting.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    version = false, -- last release is way too old and doesn't work on Windows
    build = function()
      local TS = require 'nvim-treesitter'
      if not TS.get_installed then
        GaVim.error 'Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.'
        return
      end
      -- make sure we're using the latest treesitter util
      package.loaded['gavim.util.treesitter'] = nil
      GaVim.treesitter.build(function()
        TS.update(nil, { summary = true })
      end)
    end,
    event = { 'LazyFile', 'VeryLazy' },
    cmd = { 'TSUpdate', 'TSInstall', 'TSLog', 'TSUninstall' },
    opts_extend = { 'ensure_installed' },
    opts = {
      -- GaVim config for treesitter
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'docker',
        'elixir',
        'eex',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'luap',
        'markdown',
        'markdown_inline',
        'printf',
        'python',
        'query',
        'regex',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },
    },
    config = function(_, opts)
      local TS = require 'nvim-treesitter'

      setmetatable(require 'nvim-treesitter.install', {
        __newindex = function(_, k)
          if k == 'compilers' then
            vim.schedule(function()
              GaVim.error {
                'Setting custom compilers for `nvim-treesitter` is no longer supported.',
                '',
                'For more info, see:',
                '- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)',
              }
            end)
          end
        end,
      })

      -- some quick sanity checks
      if not TS.get_installed then
        return GaVim.error 'Please use `:Lazy` and update `nvim-treesitter`'
      elseif type(opts.ensure_installed) ~= 'table' then
        return GaVim.error '`nvim-treesitter` opts.ensure_installed must be a table'
      end

      -- setup treesitter
      TS.setup(opts)
      GaVim.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(function(lang)
        return not GaVim.treesitter.have(lang)
      end, opts.ensure_installed or {})
      if #install > 0 then
        GaVim.treesitter.build(function()
          TS.install(install, { summary = true }):await(function()
            GaVim.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('gavim_treesitter', { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not GaVim.treesitter.have(ft) then
            return
          end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type gavim.TSFeat
            return f.enable ~= false and not (type(f.disable) == 'table' and vim.tbl_contains(f.disable, lang)) and GaVim.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled('highlight', 'highlights') then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- indents
          if enabled('indent', 'indents') then
            GaVim.set_default('indentexpr', 'v:lua.GaVim.treesitter.indentexpr()')
          end

          -- folds
          if enabled('folds', 'folds') then
            if GaVim.set_default('foldmethod', 'expr') then
              GaVim.set_default('foldexpr', 'v:lua.GaVim.treesitter.foldexpr()')
            end
          end
        end,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    opts = {
      select = {
        enable = true,
        lookahead = true,
        keys = {
          ['if'] = '@function.inner',
          ['af'] = '@function.outer',
          ['ic'] = '@class.inner',
          ['ac'] = '@class.outer',
          ['id'] = '@conditional.inner',
          ['ad'] = '@conditional.outer',
          ['ao'] = '@loop.outer',
          ['io'] = '@loop.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        -- GaVim extention to create buffer-local keymaps
        keys = {
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
            [']a'] = '@parameter.inner',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
            [']A'] = '@parameter.inner',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[a'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[A'] = '@parameter.inner',
            ['[O'] = '@loop.inner',
          },
        },
      },
    },
    config = function(_, opts)
      local TS = require 'nvim-treesitter-textobjects'
      if not TS.setup then
        GaVim.error 'Please use `:Lazy` and update `nvim-treesitter`'
        return
      end
      TS.setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (vim.tbl_get(opts, 'move', 'enable') and GaVim.treesitter.have(ft, 'textobjects')) then
          return
        end
        ---@type table<string, table<string, string>>
        local moves = vim.tbl_get(opts, 'move', 'keys') or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == 'table' and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub('@', ''):gsub('%..*', '')
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, ' or ')
            desc = (key:sub(1, 1) == '[' and 'Prev ' or 'Next ') .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and ' End' or ' Start')
            if not (vim.wo.diff and key:find '[cC]') then
              vim.keymap.set({ 'n', 'x', 'o' }, key, function()
                require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
              end, {
                buffer = buf,
                desc = desc,
                silent = true,
              })
            end
          end
        end

        if not (vim.tbl_get(opts, 'select', 'enable')) then
          return
        end

        local selections = vim.tbl_get(opts, 'select', 'keys') or {}

        ---@type table<string, string>
        for key, query in pairs(selections) do
          -- @function.inner → "Select Inner Function"
          local obj, scope = query:match '@(%w+)%.(%w+)'
          local desc = ('Select %s %s'):format(scope and scope:sub(1, 1):upper() .. scope:sub(2) or '', obj and obj:sub(1, 1):upper() .. obj:sub(2) or '')

          vim.keymap.set({ 'x', 'o' }, key, function()
            require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
          end, {
            buffer = buf,
            desc = desc,
            silent = true,
          })
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('lazyvim_treesitter_textobjects', { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    'windwp/nvim-ts-autotag',
    event = 'LazyFile',
    opts = {},
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'LazyFile',
    opts = function()
      local tsc = require 'treesitter-context'
      Snacks.toggle({
        name = 'Treesitter Context',
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map '<leader>ut'

      return { mode = 'cursor', max_lines = 3, enable = false }
    end,
  },
}
