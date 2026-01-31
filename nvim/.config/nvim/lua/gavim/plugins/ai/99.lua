return {
  {
    'ThePrimeagen/99',
    opts = function(_, opts)
      local _99 = require '99'
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)

      return vim.tbl_deep_extend('force', opts or {}, {
        -- For logging that is to a file if you wish to trace through requests
        -- for reporting bugs, i would not rely on this, but instead the provided
        -- logging mechanisms within 99. This is for more debugging purposes
        logger = {
          level = _99.DEBUG,
          path = '/tmp/' .. basename .. '.99.debug',
          print_on_error = true,
        },

        provider = _99.ClaudeCodeProvider,
        model = 'anthropic/claude-opus-4-5',
        -- A new feature that is centered around tags
        completion = {
          -- Defaults to .cursor/rules
          -- I am going to disable these until i understand the
          -- problem better. Inside of cursor rules there is also
          -- application rules, which means i need to apply these
          -- differently
          -- cursor_rules = "<custom path to cursor rules>"

          -- A list of folders where you have your own SKILL.md
          -- Expected format:
          -- /path/to/dir/<skill_name>/SKILL.md
          --
          -- Example:
          -- Input Path:
          -- "scratch/custom_rules/"
          --
          -- Output Rules:
          -- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
          -- ... the other rules in that dir ...
          custom_rules = {
            'scratch/custom_rules/',
          },

          -- What autocomplete do you use. We currently only support cmp right now
          source = 'blink',
        },

        -- WARNING: if you change cwd then this is likely broken
        -- ill likely fix this in a later change
        --
        -- md_files is a list of files to look for and auto add based on the location
        -- of the originating request. That means if you are at /foo/bar/baz.lua
        -- the system will automagically look for:
        -- /foo/bar/AGENT.md
        -- /foo/AGENT.md
        -- assuming that /foo is project root (based on cwd)
        md_files = {
          'AGENT.md',
        },
      })
    end,

    keys = {
      -- Fill in function with AI
      {
        '<leader>9f',
        function()
          require('99').fill_in_function_prompt()
        end,
        desc = '99: Fill in function',
      },
      -- Visual selection AI action
      -- Note: uses last visual selection, so set to visual mode
      -- to avoid accidentally using an old selection
      {
        '<leader>9v',
        function()
          require('99').visual()
        end,
        mode = 'v',
        desc = '99: Visual action',
      },
      -- Stop all pending AI requests
      {
        '<leader>9s',
        function()
          require('99').stop_all_requests()
        end,
        mode = 'v',
        desc = '99: Stop all requests',
      },
      -- Fill in function with debug rule
      -- Example: Create ~/.rules/debug.md for custom behavior like
      -- automatically adding printf statements throughout a function
      {
        '<leader>9fd',
        function()
          require('99').fill_in_function()
        end,
        desc = '99: Fill in function (debug)',
      },
    },
  },
}
