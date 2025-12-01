return {
  'neovim/nvim-lspconfig',
  opts = {
    servers = {
      emmet_language_server = {
        filetypes_exclude = { 'markdown' },
        filetypes_include = { 'vue', 'blade', 'heex', 'elixir', 'eelixir' },
        includeLanguages = {
          elixir = 'html-eex',
          eelixir = 'html-eex',
          heex = 'html-eex',
        },
      },
    },
    setup = {
      emmet_language_server = function(_, opts)
        local function get_raw_config(server)
          local ok, ret = pcall(require, 'lspconfig.configs.' .. server)
          if ok then
            return ret
          end
          return require('lspconfig.server_configurations.' .. server)
        end

        local emmet = get_raw_config 'emmet_language_server'
        opts.filetypes = opts.filetypes or {}

        -- Add default filetypes
        vim.list_extend(opts.filetypes, emmet.default_config.filetypes)

        -- Remove excluded filetypes
        --- @param ft string
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, opts.filetypes)

        -- Add additional filetypes
        vim.list_extend(opts.filetypes, opts.filetypes_include or {})
      end,
    },
  },
}
