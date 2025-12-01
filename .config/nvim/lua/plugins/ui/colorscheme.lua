local transparent_background = true

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    transparent_background = transparent_background,
    lsp_styles = {
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
    integrations = {
      aerial = true,
      alpha = true,
      blink_cmp = {
        style = 'bordered',
      },
      cmp = true,
      dap = true,
      dap_ui = true,
      dashboard = true,
      dropbar = {
        enabled = true,
        color_mode = true, -- enable color for kind's texts, not just kind's icons
      },
      flash = true,
      fzf = true,
      grug_far = true,
      gitsigns = true,
      harpoon = true,
      headlines = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      leap = true,
      lsp_trouble = true,
      markdown = true,
      mason = true,
      mini = true,
      navic = { enabled = true, custom_bg = 'NONE' },
      neotest = true,
      neotree = true,
      noice = true,
      notify = true,
      snacks = true,
      treesitter_context = true,
      which_key = true,
    },
    highlight_overrides = {
      ---@param cp palette
      all = function(cp)
        return {
          -- For base configs
          NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
          FloatBorder = {
            fg = transparent_background and cp.blue or cp.mantle,
            bg = transparent_background and cp.none or cp.mantle,
          },

          -- Change color for cursorline
          -- CursorLineNr = { fg = cp.green },

          -- For fidget
          FidgetTask = { bg = cp.none, fg = cp.surface2 },
          FidgetTitle = { fg = cp.blue, style = { 'bold' } },

          -- For nvim-notify
          NotifyBackground = { bg = cp.base },

          -- For trouble.nvim
          TroubleNormal = { bg = transparent_background and cp.none or cp.base },

          -- For Snacks (picker)
          SnacksPickerTitle = { fg = cp.blue, style = { 'bold' } },
          SnacksPickerDir = { fg = cp.overlay1 },

          -- For blink pairs
          BlinkPairsOrange = { fg = cp.yellow, bg = transparent_background and cp.none or cp.base },
          BlinkPairsPurple = { fg = cp.pink, bg = transparent_background and cp.none or cp.base },
          BlinkPairsBlue = { fg = cp.sapphire, bg = transparent_background and cp.none or cp.base },
        }
      end,
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)

    vim.cmd.colorscheme 'catppuccin'
  end,
}
