return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'ibhagwan/fzf-lua',
  },
  keys = {
    { '<leader>odt', '<CMD>Obsidian today<CR>', desc = 'Open Obsidian Today Note' },
    { '<leader>ody', '<CMD>Obsidian today -1<CR>', desc = 'Open Obsidian Yesterday Note' },
    { '<leader>odT', '<CMD>Obsidian today +1<CR>', desc = 'Open Obsidian Tomorrow Note' },
    { '<leader>oD', '<CMD>Obsidian dailies<CR>', desc = 'Open Obsidian Daily Picker' },
    { '<leader>os', '<CMD>Obsidian quick_switch<CR>', desc = 'Obsidian Search Note' },
    { '<leader>og', '<CMD>Obsidian search<CR>', desc = 'Open Obsidian Grep Picker' },
    { '<leader>ot', '<CMD>Obsidian tags<CR>', desc = 'Open Obsidian Tag Picker' },
    { '<leader>oT', '<CMD>Obsidian toc<CR>', desc = 'Obsidian TOC of current Note' },
    { '<leader>ob', '<CMD>Obsidian backlinks<CR>', desc = 'Open Obsidian Backlinks Picker' },
    { '<leader>oN', '<CMD>Obsidian new<CR>', desc = 'Obsidian New Note' },
    { '<leader>on', '<CMD>Obsidian link_new<CR>', desc = 'Obsidian Link Note', mode = { 'n', 'v' } },
    { '<leader>or', '<CMD>Obsidian rename<CR>', desc = 'Obsidian Rename Note and Backlinks' },
    { '<leader>ow', '<CMD>Obsidian workspace<CR>', desc = 'Obsidian Switch Workspace (Vault)' },
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/vaults/personal',
        overrides = {
          notes_subdir = 'slip-box',
        },
      },
      {
        name = 'work',
        path = '~/vaults/work',
      },
    },

    legacy_commands = false,

    new_notes_location = 'notes_subdir',
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'daily notes',
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = '%Y-%m-%d',
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = '%B %-d, %Y',
      -- Optional, default tags to add to each new daily note created.
      default_tags = { 'daily-notes' },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
    },

    log_level = vim.log.levels.INFO, -- see below for full list of options 👇
    completion = {
      blink = true,
      min_chars = 2,
      create_new = true,
    },

    picker = {
      name = 'snacks.pick',
      note_mappings = {
        new = '<C-x>',
        insert_link = '<C-l>',
      },
      tag_mappings = {
        tag_note = '<C-x>',
        insert_tag = '<C-l>',
      },
    },

    templates = {
      folder = 'templates',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
      substitutions = {
        -- Title Case: "my cool note" -> "My Cool Note"
        titlecase = function(ctx)
          local title = ctx.spec.title or ''
          return title:gsub('(%a)([%w]*)', function(first, rest)
            return first:upper() .. rest:lower()
          end)
        end,
      },
    },

    ---@param title string|nil
    ---@return string
    note_id_func = function(title)
      local timestamp = tostring(os.time())
      local suffix

      if title and title:match '%S' then
        -- kebab-case: "My Cool Note" -> "my-cool-note"
        suffix = title:lower():gsub('%s+', '-'):gsub('[^%w%-]', '')
      else
        -- Random 4 uppercase letters
        suffix = ''
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end

      return timestamp .. '-' .. suffix
    end,
  },
}
