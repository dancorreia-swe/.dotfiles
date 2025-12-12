return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local sk = require('util').opts 'sidekick.nvim' ---@type sidekick.Config|{}

      if vim.tbl_get(sk, 'nes', 'enabled') ~= false then
        opts.servers = opts.servers or {}
        opts.servers.copilot = opts.servers.copilot or {}
      end
    end,
  },
  {
    'folke/sidekick.nvim',
    opts = function()
      -- Accept inline suggestions or next edits
      require('util.cmp').actions.ai_nes = function()
        local Nes = require 'sidekick.nes'
        if Nes.have() and (Nes.jump() or Nes.apply()) then
          return true
        end
      end

      Snacks.toggle({
        name = 'Sidekick NES',
        get = function()
          return require('sidekick.nes').enabled
        end,
        set = function(state)
          require('sidekick.nes').enable(state)
        end,
      }):map '<leader>uN'

      return {
        cli = {
          mux = {
            backend = 'zellij',
            enabled = true,
          },
        },
      }
    end,
    keys = {
      { '<tab>', require('util.cmp').map({ 'ai_nes' }, '<tab>'), mode = { 'n' }, expr = true },
      { '<leader>a', '', desc = '+ai', mode = { 'n', 'v' } },
      {
        '<c-.>',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle',
        mode = { 'n', 't', 'i', 'x' },
      },
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle CLI',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = 'Select CLI',
      },
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Detach a CLI Session',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'x', 'n' },
        desc = 'Send This',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Send File',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = { 'x' },
        desc = 'Send Visual Selection',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
    },
  },
}
