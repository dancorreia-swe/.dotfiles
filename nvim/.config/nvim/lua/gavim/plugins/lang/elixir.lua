return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local lspconfig = require 'lspconfig'
      local configs = require 'lspconfig.configs'

      -- Shim expert if missing
      if not configs.expert then
        configs.expert = {
          default_config = {
            cmd = { 'expert' },
            filetypes = { 'elixir', 'eelixir', 'heex' },
            root_dir = lspconfig.util.root_pattern('mix.exs', '.git'),
            single_file_support = true,
          },
          docs = {
            description = [[
https://github.com/elixir-expert/expert

Expert is the official language server implementation for the Elixir programming language.
]],
          },
        }
      end

      -- Enable it through LazyVim's opts.servers
      opts.servers = opts.servers or {}
      opts.servers.expert = {}
    end,
  },

  {
    'mason-org/mason.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        'expert',
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'elixir', 'heex', 'eex' })
      vim.treesitter.language.register('markdown', 'livebook')
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'jfpedroza/neotest-elixir',
    },
    opts = {
      adapters = {
        ['neotest-elixir'] = {},
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = {
        elixir = { 'credo' },
      }

      opts.linters = {
        credo = {
          condition = function(ctx)
            return vim.fs.find({ '.credo.exs' }, { path = ctx.filename, upward = true })[1]
          end,
        },
      }
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    optional = true,
    ft = function(_, ft)
      vim.list_extend(ft, { 'livebook' })
    end,
  },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function()
      local dap = require 'dap'

      -- Find debug_adapter.sh from Mason or system path
      local function get_debugger()
        local mason_path = vim.fn.expand '~/.local/share/nvim/mason/packages/elixir-ls/debug_adapter.sh'
        if vim.fn.filereadable(mason_path) == 1 then
          return mason_path
        end
        -- Fallback to system path
        local elixir_ls = vim.fn.exepath 'elixir-ls'
        if elixir_ls ~= '' then
          local dir = vim.fn.fnamemodify(elixir_ls, ':h')
          return dir .. '/debug_adapter.sh'
        end
        return nil
      end

      local debugger = get_debugger()
      if not debugger then
        return
      end

      dap.adapters.mix_task = {
        type = 'executable',
        command = debugger,
        args = {},
      }

      dap.defaults.elixir.exception_breakpoints = {}

      dap.configurations.elixir = {
        -- Phoenix server config
        {
          type = 'mix_task',
          name = 'phoenix server',
          task = 'phx.server',
          request = 'launch',
          projectDir = '${workspaceFolder}',
          exitAfterTaskReturns = false,
          debugAutoInterpretAllModules = false,
          -- IMPORTANT: Change these patterns to match your app!
          -- debugInterpretModulesPatterns = { 'MyCoolApp*', 'MyCoolAppWeb*' },
          env = { MIX_ENV = 'dev' },
        },
        -- Mix test config
        {
          type = 'mix_task',
          name = 'mix test',
          task = 'test',
          taskArgs = { '--trace' },
          request = 'launch',
          projectDir = '${workspaceFolder}',
          requireFiles = {
            'test/**/test_helper.exs',
            'test/**/*_test.exs',
          },
        },
      }
    end,
  },
}
