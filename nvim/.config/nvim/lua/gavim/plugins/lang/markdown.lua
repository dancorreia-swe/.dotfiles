--- markdownlint only runs where the project opted in with a config file, so
--- notes, agent plans, CLAUDE.md/AGENTS.md etc. aren't flooded with style
--- diagnostics (MD013 line length, ...) or rewritten on save.
---@param dirname string
local function has_markdownlint_config(dirname)
  return vim.fs.find({
    '.markdownlint.json',
    '.markdownlint.jsonc',
    '.markdownlint.yaml',
    '.markdownlint.yml',
    '.markdownlint.cjs',
    '.markdownlint.mjs',
    '.markdownlint-cli2.jsonc',
    '.markdownlint-cli2.yaml',
    '.markdownlint-cli2.cjs',
    '.markdownlint-cli2.mjs',
  }, { path = dirname, upward = true })[1] ~= nil
end

return {
  {
    'stevearc/conform.nvim',
    optional = true,
    opts = {
      formatters = {
        ['markdown-toc'] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find '<!%-%- toc %-%->' then
                return true
              end
            end
          end,
        },
        ['markdownlint-cli2'] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == 'markdownlint'
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      -- prettier only runs with a project prettier config (see coding/conform.lua)
      formatters_by_ft = {
        ['markdown'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
      },
    },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'markdownlint-cli2', 'markdown-toc' } },
  },
  {
    'mfussenegger/nvim-lint',
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint-cli2' },
      },
      linters = {
        ['markdownlint-cli2'] = {
          condition = function(ctx)
            return has_markdownlint_config(ctx.dirname)
          end,
        },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        -- links, headings and references across markdown files
        marksman = {},
      },
    },
  },

  -- Markdown preview in the browser
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = function()
      require('lazy').load { plugins = { 'markdown-preview.nvim' } }
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      {
        '<leader>cp',
        ft = 'markdown',
        '<cmd>MarkdownPreviewToggle<cr>',
        desc = 'Markdown Preview',
      },
    },
    config = function()
      vim.cmd [[do FileType]]
    end,
  },

  -- In-buffer rendering (headings, tables, checkboxes, callouts, code blocks)
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'rmd' },
    opts = {
      preset = 'obsidian',
      completions = { lsp = { enabled = true } },
      -- no latex parser / converter installed; avoids health warnings
      latex = { enabled = false },
      code = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },
      heading = { sign = false },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      Snacks.toggle({
        name = 'Render Markdown',
        get = require('render-markdown').get,
        set = require('render-markdown').set,
      }):map '<leader>um'
    end,
  },
}
