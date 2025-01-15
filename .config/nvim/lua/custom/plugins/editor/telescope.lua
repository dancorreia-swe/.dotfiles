return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    { 'LukasPietzschmann/telescope-tabs' },
    { 'debugloop/telescope-undo.nvim' },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        -- mappings = {
        --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        -- },
        -- file_ignore_patterns = { '.git/', 'vendor/', 'node_modules/', 'dist/', '.github/', '.cache', '/public/build/' },
      },
      -- pickers = {
      --   find_files = {
      --     find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
      --   },
      -- },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
        file_browser = {
          -- disables netrw and use telescope-file-browser in its place
          initial_mode = 'normal',
        },
        undo = {},
      },

      -- You can specify your own layouts for the preview window
      -- See `:help telescope.layout` for more information
      -- layout_config = {
      --   preview_cutoff = 120,
      --   width = 0.75,
      --   height = 0.65,
      --   prompt_position = 'top',
      --   horizontal = { mirror = false },
      --   vertical = { mirror = false },
      --   flex = { horizontal = { preview = 0.5 }, vertical = { preview = 0.5 } },
      --   cursor = 1,
      --   preview = 1,
      --   prompt = 1,
      --   results = 1,
      --   preview_width = 0.5,
      --   mirror = false,
      --   ignore_floating = false,
      --   ignore_term = false,
      --   use_less = false,
      --   set_env = { ['COLORTERM'] = 'truecolor' },
      -- },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'telescope-tabs')
    pcall(require('telescope').load_extension, 'file_browser')
    pcall(require('telescope').load_extension, 'undo')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    local tabs = require 'telescope-tabs'

    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sF', function()
      builtin.find_files { no_ignore = true, hidden = true }
    end, { desc = '[S]earch all [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sG', builtin.git_status, { desc = '[S]earch [G]it Changed Files' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', function()
      builtin.buffers { sort_lastused = true }
    end, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>st', tabs.list_tabs, { desc = '[S]earch [T]abs' })
    vim.api.nvim_set_keymap('n', '<space>fb', ':Telescope file_browser<CR>', { noremap = true, desc = '[F]ile [B]rowser' })
    vim.api.nvim_set_keymap(
      'n',
      '<space>fB',
      ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
      { noremap = true, desc = '[F]ile Browser of current [Buffer]' }
    )
    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Shortcut for undo history
    vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>', { desc = '[U]ndo History' })

    local ts_group = vim.api.nvim_create_augroup('TelescopeOnEnter', { clear = true })
    vim.api.nvim_create_autocmd({ 'VimEnter' }, {
      callback = function()
        local first_arg = vim.v.argv[3]
        if first_arg and vim.fn.isdirectory(first_arg) == 1 then
          -- Vim creates a buffer for folder. Close it.
          vim.cmd ':bd 1'
          require('telescope.builtin').find_files { search_dirs = { first_arg } }
        end
      end,
      group = ts_group,
    })
  end,
}
