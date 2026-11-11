return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  -- Only load for notes inside a vault (or via the keymaps below), so markdown
  -- files elsewhere don't trigger obsidian.nvim.
  event = {
    'BufReadPre ' .. vim.fn.expand '~' .. '/Obsidian/*.md',
    'BufNewFile ' .. vim.fn.expand '~' .. '/Obsidian/*.md',
  },
  cmd = 'Obsidian',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
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
    { '<leader>on', '<CMD>Obsidian link_new<CR>', desc = 'Obsidian Link New Note', mode = { 'n', 'v' } },
    { '<leader>ol', '<CMD>Obsidian link<CR>', desc = 'Obsidian Link Note', mode = { 'n', 'v' } },
    { '<leader>or', '<CMD>Obsidian rename<CR>', desc = 'Obsidian Rename Note and Backlinks' },
    { '<leader>ow', '<CMD>Obsidian workspace<CR>', desc = 'Obsidian Switch Workspace (Vault)' },
  },
  opts = {
    workspaces = {
      {
        name = 'atlas',
        path = '~/Obsidian/atlas',
        overrides = {
          daily_notes = {
            folder = 'Calendar/Daily',
          },
          templates = {
            folder = '_templates',
          },
          attachments = {
            folder = '_attachments',
          },
        },
      },
      {
        name = 'grimoire',
        path = '~/Obsidian/grimoire',
        overrides = {
          new_notes_location = 'current_dir',
          templates = {
            folder = '99 - Templates',
          },
        },
      },
    },

    legacy_commands = false,
    -- render-markdown.nvim draws checkboxes, links and headings; obsidian's own
    -- UI layer would render on top of it (see :checkhealth render-markdown)
    ui = { enable = false },
    new_notes_location = 'notes_subdir',
    daily_notes = {
      date_format = '%Y-%m-%d',
      alias_format = '%B %-d, %Y',
      default_tags = { 'daily-notes' },
      -- The vault's Daily template uses Templater syntax, which obsidian.nvim can't expand.
      template = nil,
    },

    log_level = vim.log.levels.INFO, -- see below for full list of options 👇

    picker = {
      name = 'snacks.picker',
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
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
      substitutions = {
        titlecase = function(ctx)
          local title = ctx.partial_note and ctx.partial_note:display_name() or ''
          return (title:gsub('(%a)([%w]*)', function(first, rest)
            return first:upper() .. rest:lower()
          end))
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
