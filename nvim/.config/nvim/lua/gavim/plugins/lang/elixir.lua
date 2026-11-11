return {
  {
    -- `expert` ships with nvim-lspconfig (lsp/expert.lua), no shim needed
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        expert = {
          settings = {
            workspaceSymbols = {
              minQueryLength = 0,
            },
          },
        },
      },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'expert' } },
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
    'mfussenegger/nvim-lint',
    optional = true,
    -- merged into coding/lint.lua's opts
    opts = {
      linters_by_ft = {
        elixir = { 'credo' },
      },
      linters = {
        credo = {
          condition = function(ctx)
            return vim.fs.find({ '.credo.exs' }, { path = ctx.dirname, upward = true })[1]
          end,
        },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    optional = true,
    ft = function(_, ft)
      vim.list_extend(ft, { 'livebook' })
    end,
  },
}
