return {
  'neovim/nvim-lspconfig',
  opts = {
    servers = {
      tailwindcss = {
        -- filetypes to drop from / add to the nvim-lspconfig defaults
        filetypes_exclude = { 'markdown' },
        filetypes_include = {},
        settings = {
          tailwindCSS = {
            -- Phoenix templates
            includeLanguages = {
              elixir = 'html-eex',
              eelixir = 'html-eex',
              heex = 'html-eex',
            },
          },
        },
      },
    },
    setup = {
      tailwindcss = function(_, opts)
        -- defaults come from nvim-lspconfig's lsp/tailwindcss.lua
        local defaults = vim.lsp.config.tailwindcss or {}
        local filetypes = vim.list_extend(vim.deepcopy(opts.filetypes or defaults.filetypes or {}), opts.filetypes_include or {})
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, filetypes)
        -- not part of vim.lsp.Config
        opts.filetypes_exclude, opts.filetypes_include = nil, nil
      end,
    },
  },
}
