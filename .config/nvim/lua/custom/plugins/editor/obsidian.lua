return {
  'obsidian-nvim/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = false,
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
    -- Required.
    'nvim-lua/plenary.nvim',
    'ibhagwan/fzf-lua',
  },
  keys = {
    { '<leader>odt', '<CMD>Obsidian today<CR>', desc = 'Open Obsidian today note' },
    { '<leader>ody', '<CMD>Obsidian today -1<CR>', desc = 'Open Obsidian yesterday note' },
    { '<leader>odT', '<CMD>Obsidian today +1<CR>', desc = 'Open Obsidian tomorrow note' },
    { '<leader>oD', '<CMD>Obsidian dailies<CR>', desc = 'Open Obsidian daily picker' },
    { '<leader>og', '<CMD>Obsidian search<CR>', desc = 'Open Obsidian grep picker' },
    { '<leader>ot', '<CMD>Obsidian tags<CR>', desc = 'Open Obsidian tag picker' },
    { '<leader>ob', '<CMD>Obsidian backlinks<CR>', desc = 'Open Obsidian backlinks picker' },
    { '<leader>on', '<CMD>Obsidian new<CR>', desc = 'Obsidian new note' },
  },
  config = function()
    require('obsidian').setup {
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
      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'.
        -- You may have as many periods in the note ID as you'd like—the ".md" will be added automatically
        local suffix = ''
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. '-' .. suffix
      end,

      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ['gf'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        -- Toggle check-boxes.
        ['<leader>ch'] = {
          action = function()
            return require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context, either follow link or toggle checkbox.
        ['<cr>'] = {
          action = function()
            return require('obsidian').util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },

      picker = {
        name = 'snacks.pick',
        -- Optional, configure key mappings for the picker. These are the defaults.
        -- Not all pickers support all mappings.
        note_mappings = {
          -- Create a new note from your query.
          new = '<C-x>',
          -- Insert a link to the selected note.
          insert_link = '<C-l>',
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = '<C-x>',
          -- Insert a tag at the current location.
          insert_tag = '<C-l>',
        },
      },

      ---@class obsidian.config.AttachmentsOpts
      ---
      ---Default folder to save images to, relative to the vault root.
      ---@field img_folder? string
      ---
      ---Default name for pasted images
      ---@field img_name_func? fun(): string
      ---
      ---Default text to insert for pasted images
      ---@field img_text_func? fun(client: obsidian.Client, path: obsidian.Path): string
      ---
      ---Whether to confirm the paste or not. Defaults to true.
      ---@field confirm_img_paste? boolean
      attachments = {
        img_folder = 'assets/imgs',
        img_text_func = function(client, path)
          local encoded_path = require('obsidian.util').urlencode(path:vault_relative_path() or tostring(path))
          return string.format('![%s](%s)', path.name, encoded_path)
        end,
        img_name_func = function()
          return string.format('Pasted image %s', os.date '%Y%m%d%H%M%S')
        end,
        confirm_img_paste = true,
      },
    }
  end,
}
