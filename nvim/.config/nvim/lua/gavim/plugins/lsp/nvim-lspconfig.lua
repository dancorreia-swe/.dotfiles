return {
  -- lspconfig
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      'mason.nvim',
      { 'mason-org/mason-lspconfig.nvim', config = function() end },
    },
    opts_extend = { 'servers.*.keys' },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.Opts
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = true,
            prefix = '●',
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = GaVim.icons.icons.diagnostics.Error,
              [vim.diagnostic.severity.WARN] = GaVim.icons.icons.diagnostics.Warn,
              [vim.diagnostic.severity.HINT] = GaVim.icons.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = GaVim.icons.icons.diagnostics.Info,
            },
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = { 'vue' }, -- filetypes for which you don't want to enable inlay hints
        },
        codelens = {
          enabled = true,
        },
        folds = {
          enabled = true,
        },
        ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean, keys?:LazyKeysLspSpec[]}
        ---@type table<string, lazyvim.lsp.Config|boolean>
        servers = {
          ['*'] = {
            capabilities = {
              workspace = {
                fileOperations = {
                  didRename = true,
                  willRename = true,
                },
              },
            },
            -- stylua: ignore
            keys = {
              { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
              { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
              { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
              { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
              { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
              { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
              { "<leader>cC", function()
                  local enabled = vim.lsp.codelens.is_enabled({ bufnr = 0 })
                  vim.lsp.codelens.enable(not enabled, { bufnr = 0 })
                end, desc = "Toggle Codelens", mode = { "n" }, has = "codeLens" },
              { "<leader>cI", function()
                  local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
                  vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
                end, desc = "Toggle Inlay Hints", mode = { "n" }, has = "inlayHint" },
              { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
              { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
              { "<leader>cA", GaVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
              { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
                desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
              { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
                desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
              { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
                desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
              { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
                desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
              {
                "<leader>co",
                GaVim.lsp.action["source.organizeImports"],
                desc = "Organize Imports",
                has = "codeAction",
                enabled = function(buf)
                  local code_actions = vim.tbl_filter(function(action)
                    return action:find("^source%.organizeImports%.?$")
                  end, GaVim.lsp.code_actions({ bufnr = buf }))
                  return #code_actions > 0
                end,
              },
            },
          },
          stylua = { enabled = false },
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = false,
                },
                completion = {
                  callSnippet = 'Replace',
                },
                doc = {
                  privateName = { '^_' },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = 'Disable',
                  semicolon = 'Disable',
                  arrayIndex = 'Disable',
                },
              },
            },
          },
        },
        ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
        setup = {},
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- setup keymaps
      local names = vim.tbl_keys(opts.servers) ---@type string[]
      table.sort(names)
      for _, server in ipairs(names) do
        local server_opts = opts.servers[server]
        if type(server_opts) == 'table' and server_opts.keys then
          require('gavim.util.lsp-keymaps').set({ name = server ~= '*' and server or nil }, server_opts.keys)
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = 'textDocument/inlayHint' }, function(buffer)
          if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == '' and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- folds
      if opts.folds.enabled then
        Snacks.util.lsp.on({ method = 'textDocument/foldingRange' }, function()
          if GaVim.set_default('foldmethod', 'expr') then
            GaVim.set_default('foldexpr', 'v:lua.vim.lsp.foldexpr()')
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Snacks.util.lsp.on({ method = 'textDocument/codeLens' }, function(buffer)
          vim.lsp.codelens.enable(true, { bufnr = buffer })
        end)
      end

      -- diagnostics
      if type(opts.diagnostics.virtual_text) == 'table' and opts.diagnostics.virtual_text.prefix == 'icons' then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          local icons = GaVim.icons.icons.diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return '●'
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if opts.servers['*'] then
        vim.lsp.config('*', opts.servers['*'])
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason = GaVim.has 'mason-lspconfig.nvim'
      local mason_all = have_mason and vim.tbl_keys(require('mason-lspconfig.mappings').get_mason_map().lspconfig_to_package) or {} --[[ @as string[] ]]
      local mason_exclude = {} ---@type string[]

      ---@return boolean? exclude automatic setup
      local function configure(server)
        if server == '*' then
          return false
        end
        local sopts = opts.servers[server]
        if sopts == true then
          sopts = {}
        elseif not sopts then
          sopts = { enabled = false }
        end
        ---@cast sopts lazyvim.lsp.Config

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup['*']
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configure the server
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      if have_mason then
        require('mason-lspconfig').setup {
          ensure_installed = vim.list_extend(install, GaVim.opts('mason-lspconfig.nvim').ensure_installed or {}),
          automatic_enable = { exclude = mason_exclude },
        }
      end
    end,
  },

  -- cmdline tools and lsp servers
  {

    'mason-org/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = ':MasonUpdate',
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger {
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
