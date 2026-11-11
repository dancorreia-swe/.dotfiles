return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'php', 'php_only', 'blade', 'phpdoc' } },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        intelephense = {},
      },
    },
  },
}
