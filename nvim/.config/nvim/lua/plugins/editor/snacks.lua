local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = { '<C-h>', term_nav 'h', desc = 'Go to Left Window', expr = true, mode = 't' },
            nav_j = { '<C-j>', term_nav 'j', desc = 'Go to Lower Window', expr = true, mode = 't' },
            nav_k = { '<C-k>', term_nav 'k', desc = 'Go to Upper Window', expr = true, mode = 't' },
            nav_l = { '<C-l>', term_nav 'l', desc = 'Go to Right Window', expr = true, mode = 't' },
          },
        },
      },
      dashboard = {
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'y', desc = 'Yazi', action = '<cmd>Yazi<cr>' },
            { icon = ' ', key = 'o', desc = 'Obsidian Vault', action = ':e ~/vaults/personal/' },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        width = 60,
        pane_gap = 16,
        sections = {
          {
            section = 'header',
            align = 'center',
            enabled = function()
              return not (vim.o.columns > 135)
            end,
          },
          {
            pane = 1,
            {
              section = 'terminal',
              cmd = (function()
                local gif = vim.fn.stdpath 'config' .. '/lua/plugins/dashboard-pics/silf-wolf.gif'
                if vim.fn.executable 'chafa' == 1 and vim.fn.filereadable(gif) == 1 then
                  return string.format('chafa -f symbols --symbols sextant -c full --speed=0.9 --clear --stretch --probe off %q; sleep .1', gif)
                end
                return 'echo ""' -- fallback: show nothing
              end)(),
              height = 32,
              width = 72,
              padding = 1,
              enabled = function()
                return vim.o.columns > 135 and vim.fn.executable 'chafa' == 1
              end,
            },
            {
              section = 'startup',
              padding = 1,
              enabled = function()
                return vim.o.columns > 135
              end,
            },
          },
          {
            pane = 2,
            { section = 'keys', padding = 2, gap = 1 },
            {
              icon = ' ',
              title = 'Recent Files',
            },
            {
              section = 'recent_files',
              opts = { limit = 3 },
              indent = 2,
              padding = 1,
            },
            {
              icon = ' ',
              title = 'Projects',
            },
            {
              section = 'projects',
              opts = { limit = 3 },
              indent = 2,
              padding = 1,
            },
            {
              section = 'startup',
              padding = 1,
              enabled = function()
                return not (vim.o.columns > 135)
              end,
            },
          },
        },
      },
      indent = { enabled = false },
      input = { enabled = true },
      picker = {
        sources = {
          explorer = {
            layout = {
              layout = {
                position = 'right',
              },
            },
          },
          todo_comments = {
            show_empty = true,
          },
        },
        enabled = true,
        win = {
          -- input window
          input = {
            keys = {
              ['<c-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
            },
          },
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      lazygit = { enabled = true },
      explorer = { enabled = true },
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 20, total = 120 },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- Terminal 
      { "<leader>fT", function() Snacks.terminal() end, desc = "Terminal (cwd)" },
      { "<leader>ft", function() Snacks.terminal(nil, {GaVim.root()}) end, desc = "Terminal (Root Dir)"},
      { "<c-/>", function() Snacks.terminal(nil, {GaVim.root()}) end, desc = "Terminal (Root Dir)", mode = {"n", "t"}},
      { "c-_", function() Snacks.terminal(nil, { cwd = GaVim.root() }) end, desc = "which_key_ignore"},

      -- Top Pickers & Explorer
      { "<leader><cr>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },

      -- find

      ---@diagnostic disable-next-line: assign-type-mismatch
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },

      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },

      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sL", function() Snacks.picker.picker_layouts() end, desc = "Picker Layouts" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },

      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
      { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

      -- Lazygit
      { "<leader>lg", function() Snacks.lazygit.open() end, desc = "[L]azy[g]it" },

      -- Buffer
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

      -- Other
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>N", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },

      -- lua
      { "<localleader>r", function() Snacks.debug.run() end, desc = "Run Lua", ft = "lua", mode = { "n", "x" } },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
          vim.g.snacks_copilot_enabled = true

          -- Create some toggle mappings
          Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
          Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
          Snacks.toggle.diagnostics():map '<leader>ud'
          Snacks.toggle.line_number():map '<leader>ul'
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
          Snacks.toggle.treesitter():map '<leader>uT'
          Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
          Snacks.toggle.inlay_hints():map '<leader>uh'
          Snacks.toggle.indent():map '<leader>ug'
          Snacks.toggle.dim():map '<leader>uD'
          Snacks.toggle({
            name = 'Copilot Suggestions',
            get = function()
              return vim.g.snacks_copilot_enabled
            end,
            set = function(state)
              if state then
                vim.g.snacks_copilot_enabled = true
                require('copilot.command').enable()
              else
                vim.g.snacks_copilot_enabled = false
                require('copilot.command').disable()
              end
            end,
          }):map '<leader>ua' -- ai
        end,
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    optional = true,
    keys = {
      {
        '<Leader>st',
        function()
          ---@diagnostic disable-next-line: undefined-field
          Snacks.picker.todo_comments()
        end,
        desc = 'Todo',
      },
      {
        '<Leader>sT',
        function()
          ---@diagnostic disable-next-line: undefined-field
          Snacks.picker.todo_comments {
            keywords = { 'TODO', 'FIX', 'FIXME' },
          }
        end,
        desc = 'Todo/Fix/Fixme',
      },
    },
  },
  {
    'folke/trouble.nvim',
    optional = true,
    specs = {
      'folke/snacks.nvim',
      opts = function(_, opts)
        return vim.tbl_deep_extend('force', opts or {}, {
          picker = {
            actions = require('trouble.sources.snacks').actions,
            win = {
              input = {
                keys = {
                  ['<a-t>'] = {
                    'trouble_open',
                    mode = { 'n', 'i' },
                  },
                },
              },
            },
          },
        })
      end,
    },
  },
  {
    'folke/edgy.nvim',
    ---@module 'edgy'
    ---@param opts Edgy.Config
    opts = function(_, opts)
      for _, pos in ipairs { 'top', 'bottom', 'left', 'right' } do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = 'snacks_terminal',
          size = { height = 0.4 },
          title = '%{b:snacks_terminal.id}: %{b:term_title}',
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == 'editor'
              and not vim.w[win].trouble_preview
          end,
        })
      end
    end,
  },
  {
    'gitsigns.nvim',
    opts = function()
      Snacks.toggle({
        name = 'Git Signs',
        get = function()
          return require('gitsigns.config').config.signcolumn
        end,
        set = function(state)
          require('gitsigns').toggle_signs(state)
        end,
      }):map '<leader>uG'
    end,
  },
}
