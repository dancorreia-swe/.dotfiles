local transparent_background = false

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  opts = {
    transparent_background = transparent_background,
    -- integrations are listed below; auto-detection calls vim.pack.get(), which
    -- creates site/pack/core and makes lazy.nvim's health check complain
    auto_integrations = false,
    lsp_styles = {
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
    integrations = {
      blink_cmp = {
        style = 'bordered',
      },
      dropbar = {
        enabled = true,
        color_mode = true, -- enable color for kind's texts, not just kind's icons
      },
      flash = true,
      grug_far = true,
      gitsigns = true,
      harpoon = true,
      lsp_trouble = true,
      markdown = true,
      mason = true,
      mini = true,
      noice = true,
      snacks = true,
      render_markdown = true,
      treesitter_context = true,
      which_key = true,
    },
    -- per-group overrides: highlight_overrides = { all = function(cp) return { ... } end }
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)

    vim.cmd.colorscheme 'catppuccin'
  end,
}
